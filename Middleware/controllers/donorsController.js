// Controller

let mysql = require('mysql')
let config = require('../helpers/config') //Import
let connection = mysql.createConnection(config)

//Get all donors  
module.exports.get_donors = (request, response) => {
  // let sql = "SELECT * FROM Donor"
  let sql = `CALL GetDonors()`
  connection.query(sql, (error, results, fields) => {
    if(error) {
      response.send(error)
    }
    response.json(results)
  })
}

//Get a specific donor
module.exports.get_donor = (request, response) => {
  let sql = "CALL GetDonor(?)"
  connection.query(sql, [request.params.id] ,(error, results, fields) => {
    if(error) {
      response.send(error)
    }
    response.json(results)
  })
}

//Add a new donor
module.exports.add_donor = (request, response) => {
  // let sql = "CALL CreateDonor(?, ?, ?, ?, ?, ?, ?)"
  // connection.query(sql, 
  //   [
  //     request.query.name,
  //     request.query.city,
  //     request.query.colony,
  //     request.query.organization,
  //     request.query.website1,
  //     request.query.website2,
  //     request.query.cfdi,
  //   ],
  //   (error, results, fields) => {
  //   if(error) {
  //     response.send(error)
  //   }
  //   response.json(results)
  // })
  
  let sql = "CALL CreateDonor(?)"
  // send Json object
  connection.query(
      sql,
      JSON.stringify(request.body),
      (error, results, fields) => {
        if(error) {
          response.send(error)
        }
        response.json(results)
      })
}

//Delete a specific donor
module.exports.delete_donor = (request, response) => {
  let sql = "CALL DeleteDonor(?)"
  connection.query(sql, [request.params.id], (error, results, fields) => {
    if(error) {
      response.send(error)
    }
    response.json(results)
  })
}

//Update a specific donor
module.exports.update_donor = (request, response) => {
  let sql = "UPDATE Donor SET donor_name = ?, donor_city = ?, donor_colony = ?, donor_organization = ?, donor_website1 = ?, donor_website2 = ?, donor_cfdi = ?";
  connection.query(sql,
    [
      request.query.name,
      request.query.city,
      request.query.colony,
      request.query.organization,
      request.query.website1,
      request.query.website2,
      request.params.cfdi
    ], (error, results, fields) => {
    if(error) {
      response.send(error)
    }
    response.json(results)
  })
}