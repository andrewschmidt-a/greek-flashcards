const { NetlifyJwtVerifier } = require('@serverless-jwt/netlify');
const CSV = require('comma-separated-values')
const fs = require('fs')

const verifyJwt = NetlifyJwtVerifier({
  issuer: 'https://nemcrunchers.auth0.com/',
  audience: 'Gxd73MGuYFuKwMnLAbvd8OlKKx5JBfwW'
});

exports.handler = verifyJwt(async (event, context) => {
  const { claims } = context.identityContext;
  return {
    statusCode: 200,
    body: JSON.stringify({
        "Chapter1": CSV.parse(fs.readFileSync(require.resolve(`./Chapter1.csv`), 'utf-8')),
        "Chapter2": CSV.parse(fs.readFileSync(require.resolve(`./Chapter2.csv`), 'utf-8'))
    }),
  }
});