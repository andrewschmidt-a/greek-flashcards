const CSV = require('comma-separated-values')
const fs = require('fs')

exports.handler = async event => {
    const subject = event.queryStringParameters.name || 'World'
    return {
      statusCode: 200,
      body: JSON.stringify({
          "Chapter1": CSV.parse(fs.readFileSync(require.resolve(`./Chapter1.csv`), 'utf-8')),
          "Chapter2": CSV.parse(fs.readFileSync(require.resolve(`./Chapter2.csv`), 'utf-8'))
      }),
    }
  }