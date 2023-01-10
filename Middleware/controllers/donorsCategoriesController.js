// Controller

let mysql = require('mysql')
let config = require('../helpers/config') //Import
let connection = mysql.createConnection(config)

//Get category for a specific donor
module.exports.get_categories = (request, response) => {
    let sql = "SELECT * FROM Category";
    connection.query(sql, (error, results, fields) => {
        if(error) {
            response.send(error)
        }
        response.json(results)
    })
}

//Get category for a specific donor
module.exports.get_category = (request, response) => {
    // let sql = "SELECT cat_name FROM Category WHERE cat_id = (SELECT category_id FROM DonorCategory WHERE donor_id = ?)";
    let sql = "SELECT cat_name FROM Category WHERE cat_id IN (SELECT category_id FROM DonorCategory WHERE donor_id = ?)";
    connection.query(sql, [request.params.id], (error, results, fields) => {
        if(error) {
            response.send(error)
        }
        response.json(results)
    })
}

//Post a new category
module.exports.add_category = (request, response) => {
    let sql = "INSERT INTO Category VALUES(null, ?)";
    connection.query(sql, request.query.newCategory, (error, results, fields) => {
        if(error) {
            response.send(error)
        }
        response.json(results)
    })
}

//Delete a category
module.exports.delete_category = (request, response) => {
    let sql = "DELETE FROM Category WHERE cat_id = ?";
    connection.query(sql, request.params.id, (error, results, fields) => {
        if(error) {
            response.send(error)
        }
        response.json(results)
    })
}