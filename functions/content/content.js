const { NetlifyJwtVerifier } = require('@serverless-jwt/netlify');
const CSV = require('comma-separated-values')
const fs = require('fs')
const _ = require('lodash');

const verifyJwt = NetlifyJwtVerifier({
  issuer: 'https://nemcrunchers.auth0.com/',
  audience: 'Gxd73MGuYFuKwMnLAbvd8OlKKx5JBfwW'
});
const withoutAuth = async (event, context) => {
  const { claims } = context.identityContext;
  let path = event.queryStringParameters.path? event.queryStringParameters.path: "./index.json";

  var fileContents = fs.readFileSync(require.resolve(path));
  let returnValue = ""

  if(path.endsWith(".json")){// This is an intermediate node and will be parsed as json
    let fileJSON = JSON.parse(fileContents);
  
    returnValue = fileJSON.map(el => {
      if(_.has(el, 'path')){
        let pathComponents = path.split("/");
        pathComponents[pathComponents.length-1] = el['path'];
        return _.merge(el, {"path": pathComponents.join('/')});
      }else{
        return el;
      }
    });
  }else{
    returnValue = fileContents.toString(); // return the raw content. The files must be relatively small. No hosting videos here!
  }

  return {
    statusCode: 200,
    body: JSON.stringify(returnValue),
  }
}

const withAuth = verifyJwt(withoutAuth);


exports.handler = async (event, context) => {
  let allowedPaths = [
    "./index.json",
    "",
    undefined,
    null
  ];
  if(allowedPaths.includes(event.queryStringParameters.path)){
    context.identityContext = {claims: {}}; // add this to avoid error in next function call
    return await withoutAuth(event, context);
  }else{
    return await withAuth(event, context);
  }
};