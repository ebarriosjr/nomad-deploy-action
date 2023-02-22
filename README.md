# nomad-deploy-action
This repo will take a Nomad job, replace variables and deploy the job file.

## Environment Variables

| Variable   | Details                  | Example                    | Default            |
|------------|--------------------------|----------------------------|--------------------|
| NOMAD_JOB  | The Nomad job file path. | `nomad-jobs/dev/app.nomad` |                  |
| NOMAD_ADDR | The remote Nomad url.    | `https://example.com`      | `http://127.0.0.1` |
| NOMAD_PORT | The remote Nomad port.   | `4646`                     | `4646`             |
| VARIABLES  | Variables needed to template the file. Format variable=value. Space separated| |
