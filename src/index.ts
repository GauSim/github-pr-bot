import * as express from 'express';
// import * as bodyParser from 'body-parser';

const port = process.env.PORT || 8080;
const createHandler = require('github-webhook-handler')

type ParsedRequest = { body: any } & express.Request;


const handler = createHandler({ path: '/webhook', secret: 'test' })
handler.on('*', function (event:{payload:any}) {

  const { pull_request } = event.payload as {
    action: 'opened';
    pull_request: {
      title: string;
      user: {}
    }
  };

  console.log(pull_request);
  console.log('#############')
  console.log(pull_request['base']['repo']['full_name'])
});


const webhook = (req: ParsedRequest, res: express.Response, next: () => void) => {
  handler(req, res, _ => next());
};

var app = express();
app.use(webhook);
app.get('/', function (_, res) {
  res.send(JSON.stringify('online'));
});

app.use((_: ParsedRequest, res: express.Response) => {
  res.statusCode = 404;
  res.end('no such location');
})
app.listen(port, function () {
  console.log(`Example app listening on port ${port}!`);
});

