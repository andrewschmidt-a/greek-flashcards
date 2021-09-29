const CSV = require('comma-separated-values')
const fs = require('fs')
const resolve = require('path').resolve

exports.handler = async event => {
    const subject = event.queryStringParameters.name || 'World'
    return {
      statusCode: 200,
      body: JSON.stringify({
          "Chapter1": CSV.parse(fs.readFileSync(resolve(`./assets/Chapter1.csv`), 'utf-8')),
          "Chapter2": CSV.parse(fs.readFileSync(resolve(`./assets/Chapter2.csv`), 'utf-8'))
      }),
    }
  }