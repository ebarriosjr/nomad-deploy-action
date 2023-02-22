# nomad-deploy-action
This repo will take a Nomad job, replace variables and deploy the job file.

## Environment Variables

| Variable   | Details                  | Default            | Example                    |
|------------|--------------------------|--------------------|----------------------------|
| NOMAD_JOB  | The Nomad job file path. |                    | `nomad-jobs/dev/app.nomad` |
| NOMAD_ADDR | The remote Nomad url.    | `http://127.0.0.1` | `https://example.com`      |
| NOMAD_PORT | The remote Nomad port.   | `4646`             | `4646`                     |
| VARIABLES  | Variables needed to template the file. Format variable=value. Space separated| | |
