//Routes

let express = require('express')
let router = express.Router()

let donorsCategoriesController = require('../controllers/donorsCategoriesController');

router.get('/', donorsCategoriesController.get_categories)
router.get('/:id', donorsCategoriesController.get_category)
router.post('/:category', donorsCategoriesController.add_category)
router.delete('/:id', donorsCategoriesController.delete_category)

module.exports = router