import * as express from 'express';
import { spawn, exec } from 'child_process';
import { SECRET } from './conf';

const port = process.env.PORT || 8080;
const createHandler = require('github-webhook-handler')

type ParsedRequest = { body: any } & express.Request;


const gitClone = () => {
  return new Promise((ok, fail) => {
    const gitClone = spawn('git', ['clone', 'https://github.com/GauSim/private-push.git', 'temp']);

    gitClone.stdout.on('data', (data) => {
      console.log(`child process stdout: ${data}`);
    });

    gitClone.stderr.on('data', (data) => {
      console.log(`child process stderr: ${data}`);
    });

    gitClone.on('close', (code) => {
      console.log(`child process exited with code ${code}`);
      ok(code);
    });
  });
}

const handler = createHandler({ path: '/webhook', secret: SECRET })
handler.on('*', function (event: { payload: any }) {
  debugger;
  const { pull_request } = event.payload as {
    action: 'opened';
    pull_request: {
      title: string;
      user: {};
      base: {
        repo: {
          full_name: string;
        };
      };
      head: {
        sha: string;
      };
    }
  };


  gitClone().then(_ => {
    exec('cd temp && npm install',
      (error, stdout, stderr) => {
        debugger;
        
        if (error) {
          console.error(`exec error: ${error}`);
          return;
        }
        console.log(`stdout: ${stdout}`);
        console.log(`stderr: ${stderr}`);
      });

  });
  console.log(pull_request.base.repo.full_name)
  console.log(pull_request.head.sha);
  // git checkout sha-of-commit -b testing-a-commit


});

handler.on('error', (error) => {
  console.log(error);
})

const webhook = (req: ParsedRequest, res: express.Response, next: () => void) => handler(req, res, _ => next());

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

