//Controller

let mysql = require('mysql')
let config = require('../helpers/config') //Import
const router = require('../routes/donors')
let connection = mysql.createConnection(config)

//Get all types
module.exports.get_types = (request, response) => {
    let sql = "SELECT * FROM Type";
    connection.query(sql, (error, results, fields) => {
        if(error) {
            response.send(error)
        }
        response.json(results)
    })
}

//Get types for a specific donor
module.exports.get_donor_types = (request, response) => {
    let sql = "SELECT type_name FROM Type WHERE type_id = (SELECT type_id FROM DonorType WHERE donor_id = ?)";
    connection.query(sql, request.params.id, (error, results, fields) => {
        if(error) {
            response.send(error)
        }
        response.json(results)
    })
}

//Post a new type
module.exports.add_type = (request, response) => {
    let sql = "INSERT INTO Type VALUES(null, ?)";
    connection.query(sql, request.query.newType, (error, results, fields) => {
        if(error) {
            response.send(error)
        }
        response.json(results)
    })
}

//Delete an existing type
module.exports.delete_type = (request, response) => {
    let sql = "DELETE FROM Type WHERE type_id = ?";
    connection.query(sql, request.params.id, (error, results, fields) => {
        if(error) {
            response.send(error)
        }
        response.json(results)
    })
}