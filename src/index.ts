import * as http from 'http';
import * as express from 'express';
import * as bodyParser from 'body-parser';

const port = process.env.PORT || 8080;
const createHandler = require('github-webhook-handler')
const events = require('github-webhook-handler/events')




Object.keys(events).forEach(function (event) {
  // console.log(event, '=', events[event])
})

type ParsedRequest = { body: any } & express.Request;




let __state = null;

const handler = createHandler({ path: '/webhook', secret: 'test' })
handler.on('*', function (event:{payload:ay}) {

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
  handler(req, res, (error) => {
    next();
  });
};

var app = express();
app.use(webhook);
app.get('/', function (req, res) {
  res.send(JSON.stringify(__state));
});

app.use((req: ParsedRequest, res: express.Response) => {
  res.statusCode = 404;
  res.end('no such location');
})
app.listen(port, function () {
  console.log(`Example app listening on port ${port}!`);
});

