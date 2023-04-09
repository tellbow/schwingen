# Schwingen

## Run Locally
This will run both a Nuxt3 dev server with hot reload and a pocketbase instance with a authentication and an api ready to go.

Clone the project

```bash
  git clone https://github.com/j-wil/pocket-nuxt
```

Go to the project directory

```bash
  cd pocket-nuxt
```

Install dependencies

```bash
  yarn install
```

Start the server

```bash
  yarn dev
```

| URL                 | Function                       |
|---------------------|--------------------------------|
| localhost:8090/_/   | pocketbase admin setup and log |
| localhost:8090/api/ | pocketbase api                 |
| localhost:3000/     | nuxt3 dev server               |

From there build your nuxt app as normal. Follow the [pocketbase docs](https://pocketbase.io/docs/) for more info on how to use pocketbase.

## Deployment

This will create a single binary containing Nuxt and PocketBase for deployment.

```bash
  yarn build:prod
```

```bash
  ./pocketnuxt serve --http "yourdomain.com:80" --https "yourdomain.com:443"
```
https://pocketbase.io/docs/going-to-production/ for more examples.

## Docker

### Build

`docker build . --tag 0.0.1`

### Run

`docker run --rm --mount type=bind,source="$(pwd)"/pb_data,target=/pb_data -p 8090:8090 0.0.1`

## Acknowledgements

 - [Pocket Nuxt](https://github.com/j-wil/pocket-nuxt)
 - [PocketBase](https://github.com/pocketbase/pocketbase)
