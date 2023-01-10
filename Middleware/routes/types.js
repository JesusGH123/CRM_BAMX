//Routes

let express = require('express')
let router = express.Router()

let donorTypesController = require('../controllers/donorTypesController');

router.get('/', donorTypesController.get_types)
router.get('/:id', donorTypesController.get_donor_types)
router.post('/:type', donorTypesController.add_type)
router.delete('/:id', donorTypesController.delete_type)

module.exports = router