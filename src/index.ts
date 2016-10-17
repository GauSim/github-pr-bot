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


// pull_request
const onPR = (req: any) => {

  const { action, pull_request } = (req.body as { action: 'opened'; pull_request: { title: string } });
  console.log(action, pull_request)
}


let __state = null;

const handler = createHandler({ path: '/webhook', secret: 'test' })
handler.on('pull_request', function (event) {
  __state = event;
  console.log(event);
  console.log("HOOOOK");
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

