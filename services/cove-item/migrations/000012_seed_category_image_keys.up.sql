-- Seed image_key for all 59 category card backgrounds uploaded to Garage in #372.
-- Only top-level and mid-level categories have images; leaf sub-categories
-- (e.g. food.coffee.whole_bean) are intentionally left NULL.
-- Key format: images/categories/<slug>.jpg

UPDATE catalog.categories SET image_key = 'images/categories/alcohol.jpg'              WHERE path = 'alcohol';
UPDATE catalog.categories SET image_key = 'images/categories/alcohol-beer.jpg'          WHERE path = 'alcohol.beer';
UPDATE catalog.categories SET image_key = 'images/categories/alcohol-cider.jpg'         WHERE path = 'alcohol.cider';
UPDATE catalog.categories SET image_key = 'images/categories/alcohol-spirits.jpg'       WHERE path = 'alcohol.spirits';
UPDATE catalog.categories SET image_key = 'images/categories/alcohol-wine.jpg'          WHERE path = 'alcohol.wine';

UPDATE catalog.categories SET image_key = 'images/categories/apparel.jpg'               WHERE path = 'apparel';
UPDATE catalog.categories SET image_key = 'images/categories/apparel-accessories.jpg'   WHERE path = 'apparel.accessories';
UPDATE catalog.categories SET image_key = 'images/categories/apparel-jewelry.jpg'       WHERE path = 'apparel.jewelry';
UPDATE catalog.categories SET image_key = 'images/categories/apparel-mens.jpg'          WHERE path = 'apparel.mens';
UPDATE catalog.categories SET image_key = 'images/categories/apparel-unisex.jpg'        WHERE path = 'apparel.unisex';
UPDATE catalog.categories SET image_key = 'images/categories/apparel-womens.jpg'        WHERE path = 'apparel.womens';

UPDATE catalog.categories SET image_key = 'images/categories/art.jpg'                   WHERE path = 'art';
UPDATE catalog.categories SET image_key = 'images/categories/art-drawings.jpg'          WHERE path = 'art.drawings';
UPDATE catalog.categories SET image_key = 'images/categories/art-materials.jpg'         WHERE path = 'art.materials';
UPDATE catalog.categories SET image_key = 'images/categories/art-paintings.jpg'         WHERE path = 'art.paintings';
UPDATE catalog.categories SET image_key = 'images/categories/art-photography.jpg'       WHERE path = 'art.photography';
UPDATE catalog.categories SET image_key = 'images/categories/art-prints.jpg'            WHERE path = 'art.prints';
UPDATE catalog.categories SET image_key = 'images/categories/art-sculptures.jpg'        WHERE path = 'art.sculptures';

UPDATE catalog.categories SET image_key = 'images/categories/beauty.jpg'                WHERE path = 'beauty';
UPDATE catalog.categories SET image_key = 'images/categories/beauty-bodycare.jpg'       WHERE path = 'beauty.bodycare';
UPDATE catalog.categories SET image_key = 'images/categories/beauty-cosmetics.jpg'      WHERE path = 'beauty.cosmetics';
UPDATE catalog.categories SET image_key = 'images/categories/beauty-fragrance.jpg'      WHERE path = 'beauty.fragrance';
UPDATE catalog.categories SET image_key = 'images/categories/beauty-haircare.jpg'       WHERE path = 'beauty.haircare';
UPDATE catalog.categories SET image_key = 'images/categories/beauty-skincare.jpg'       WHERE path = 'beauty.skincare';
UPDATE catalog.categories SET image_key = 'images/categories/beauty-supplements.jpg'    WHERE path = 'beauty.supplements';

UPDATE catalog.categories SET image_key = 'images/categories/food.jpg'                  WHERE path = 'food';
UPDATE catalog.categories SET image_key = 'images/categories/food-baked-goods.jpg'      WHERE path = 'food.baked_goods';
UPDATE catalog.categories SET image_key = 'images/categories/food-beverages.jpg'        WHERE path = 'food.beverages';
UPDATE catalog.categories SET image_key = 'images/categories/food-coffee.jpg'           WHERE path = 'food.coffee';
UPDATE catalog.categories SET image_key = 'images/categories/food-condiments.jpg'       WHERE path = 'food.condiments';
UPDATE catalog.categories SET image_key = 'images/categories/food-confections.jpg'      WHERE path = 'food.confections';
UPDATE catalog.categories SET image_key = 'images/categories/food-dairy.jpg'            WHERE path = 'food.dairy';
UPDATE catalog.categories SET image_key = 'images/categories/food-fresh.jpg'            WHERE path = 'food.fresh';
UPDATE catalog.categories SET image_key = 'images/categories/food-pantry.jpg'           WHERE path = 'food.pantry';
UPDATE catalog.categories SET image_key = 'images/categories/food-preserves.jpg'        WHERE path = 'food.preserves';
UPDATE catalog.categories SET image_key = 'images/categories/food-produce.jpg'          WHERE path = 'food.produce';
-- Note: slug is "food-protein" (without trailing s) but the ltree path is "food.proteins"
UPDATE catalog.categories SET image_key = 'images/categories/food-protein.jpg'          WHERE path = 'food.proteins';
UPDATE catalog.categories SET image_key = 'images/categories/food-snacks.jpg'           WHERE path = 'food.snacks';
UPDATE catalog.categories SET image_key = 'images/categories/food-tea.jpg'              WHERE path = 'food.tea';

UPDATE catalog.categories SET image_key = 'images/categories/home.jpg'                  WHERE path = 'home';
UPDATE catalog.categories SET image_key = 'images/categories/home-decor.jpg'            WHERE path = 'home.decor';
UPDATE catalog.categories SET image_key = 'images/categories/home-furniture.jpg'        WHERE path = 'home.furniture';
UPDATE catalog.categories SET image_key = 'images/categories/home-kitchen.jpg'          WHERE path = 'home.kitchen';
UPDATE catalog.categories SET image_key = 'images/categories/home-textiles.jpg'         WHERE path = 'home.textiles';

UPDATE catalog.categories SET image_key = 'images/categories/music.jpg'                 WHERE path = 'music';
UPDATE catalog.categories SET image_key = 'images/categories/music-accessories.jpg'     WHERE path = 'music.accessories';
UPDATE catalog.categories SET image_key = 'images/categories/music-instruments.jpg'     WHERE path = 'music.instruments';
UPDATE catalog.categories SET image_key = 'images/categories/music-recorded.jpg'        WHERE path = 'music.recorded';

UPDATE catalog.categories SET image_key = 'images/categories/pets.jpg'                  WHERE path = 'pets';
UPDATE catalog.categories SET image_key = 'images/categories/pets-birds.jpg'            WHERE path = 'pets.birds';
UPDATE catalog.categories SET image_key = 'images/categories/pets-cats.jpg'             WHERE path = 'pets.cats';
UPDATE catalog.categories SET image_key = 'images/categories/pets-dogs.jpg'             WHERE path = 'pets.dogs';
UPDATE catalog.categories SET image_key = 'images/categories/pets-exotic.jpg'           WHERE path = 'pets.exotic';

UPDATE catalog.categories SET image_key = 'images/categories/plants.jpg'                WHERE path = 'plants';
UPDATE catalog.categories SET image_key = 'images/categories/plants-dried.jpg'          WHERE path = 'plants.dried';
UPDATE catalog.categories SET image_key = 'images/categories/plants-indoor.jpg'         WHERE path = 'plants.indoor';
UPDATE catalog.categories SET image_key = 'images/categories/plants-outdoor.jpg'        WHERE path = 'plants.outdoor';
UPDATE catalog.categories SET image_key = 'images/categories/plants-plantcare.jpg'      WHERE path = 'plants.plantcare';
UPDATE catalog.categories SET image_key = 'images/categories/plants-seeds.jpg'          WHERE path = 'plants.seeds';
