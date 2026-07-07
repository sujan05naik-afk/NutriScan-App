from flask import Flask, request, jsonify
import requests
import re

app = Flask(__name__)


def _pick_nutriment(nutriments, keys):
    for key in keys:
        if key in nutriments and nutriments[key] is not None:
            return nutriments[key]
    return None


def _to_float(value):
    try:
        return float(value)
    except (TypeError, ValueError):
        return None


def _extract_calories(nutriments):
    energy_kcal = _pick_nutriment(nutriments, ["energy-kcal_100g", "energy-kcal"])
    if energy_kcal is not None:
        parsed = _to_float(energy_kcal)
        if parsed is not None:
            return round(parsed, 2)

    energy_kj = _pick_nutriment(nutriments, ["energy_100g", "energy"])
    if energy_kj is not None:
        parsed = _to_float(energy_kj)
        if parsed is not None:
            return round(parsed / 4.184, 2)

    return "Not available"


def _extract_value(nutriments, keys):
    value = _pick_nutriment(nutriments, keys)
    parsed = _to_float(value)
    return parsed if parsed is not None else (value if value is not None else "Not available")


def _extract_ingredient_texts(value):
    if isinstance(value, list):
        texts = []
        for item in value:
            texts.extend(_extract_ingredient_texts(item))
        return texts

    if isinstance(value, dict):
        text = str(value.get("text", "")).strip()
        nested = _extract_ingredient_texts(value.get("ingredients"))
        return ([text] if text else []) + nested

    return []


def _clean_text(value):
    if value is None:
        return "Not available"

    if isinstance(value, list):
        text = ", ".join(item for item in _extract_ingredient_texts(value) if item)
    else:
        text = str(value)

    text = re.sub(r"<[^>]*>", "", text)
    text = re.sub(r"\s+", " ", text).strip()
    return text or "Not available"


def _extract_ingredients(product):
    return _clean_text(
        product.get("ingredients_text_en")
        or product.get("ingredients_text")
        or product.get("ingredients_text_with_allergens_en")
        or product.get("ingredients_text_with_allergens")
        or product.get("ingredients")
    )


@app.route("/barcode", methods=["GET", "POST"])
def get_barcode():
    try:
        if request.method == "POST":
            data = request.json
            barcode = data.get("barcode") if data else None
        else:
            barcode = request.args.get("barcode")

        if not barcode:
            return jsonify({"error": "Barcode missing"}), 400

        print(f"[DEBUG] Fetching barcode: {barcode}")
        
        fields = ",".join([
            "status",
            "product_name",
            "generic_name",
            "nutriments",
            "ingredients_text",
            "ingredients_text_en",
            "ingredients_text_with_allergens",
            "ingredients_text_with_allergens_en",
            "ingredients",
            "labels",
            "labels_tags",
            "categories",
            "categories_tags",
            "ingredients_analysis_tags",
        ])
        endpoints = [
            f"https://world.openfoodfacts.org/api/v2/product/{barcode}.json?fields={fields}",
            f"https://in.openfoodfacts.org/api/v2/product/{barcode}.json?fields={fields}",
            f"https://us.openfoodfacts.org/api/v2/product/{barcode}.json?fields={fields}",
        ]
        headers = {
            "User-Agent": "NutriScan-App/1.0 (+https://github.com/)"
        }
        product = None
        product_was_not_found = False

        for url in endpoints:
            try:
                response = requests.get(url, headers=headers, timeout=10)
                if response.status_code == 404:
                    product_was_not_found = True
                    continue
                if response.status_code != 200:
                    continue

                product = response.json()
                if product.get("status") == 1:
                    break

                product_was_not_found = True
            except Exception as e:
                print(f"[DEBUG] OpenFoodFacts request failed for {url}: {e}")

        if not product or product.get("status") != 1:
            if product_was_not_found:
                return jsonify({"error": "Product not found"}), 404
            return jsonify({"error": "Unable to fetch product data"}), 502

        food = product.get("product", {})
        nutriments = food.get("nutriments", {})

        result = {
            "name": food.get("product_name") or food.get("generic_name") or "Not available",
            "calories": _extract_calories(nutriments),
            "sugar": _extract_value(nutriments, ["sugars_100g", "sugars"]),
            "proteins": _extract_value(nutriments, ["proteins_100g", "proteins"]),
            "fats": _extract_value(nutriments, ["fat_100g", "fat"]),
            "carbs": _extract_value(nutriments, ["carbohydrates_100g", "carbohydrates"]),
            "labels": food.get("labels") or food.get("labels_tags"),
            "categories": food.get("categories") or food.get("categories_tags"),
            "ingredients_analysis_tags": food.get("ingredients_analysis_tags"),
            "ingredients": _extract_ingredients(food)
        }

        print(f"[DEBUG] Result: {result}")
        return jsonify(result), 200
    
    except Exception as e:
        print(f"[DEBUG] Exception: {e}")
        return jsonify({"error": f"Internal server error: {str(e)}"}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
