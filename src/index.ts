import * as http from 'http';
import * as express from 'express';
import * as bodyParser from 'body-parser';

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


const handler = createHandler({ path: '/webhook', secret: 'myhashsecret' })



handler.on('pull_request', function (event) {
  console.log(event);
  console.log("HOOOOK");
});



http.createServer((req: ParsedRequest, res: express.Response) => {

  handler(req, res, (error) => {
    res.statusCode = 404;
    res.end('no such location');
    console.log('Error', error);

  });
}).listen(1337);
console.log('Server online');