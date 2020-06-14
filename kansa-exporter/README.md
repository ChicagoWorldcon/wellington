# Kansa Exporter

Exports a Kansa `api` database for importing into https://gitlab.com/worldcon/wellington


## Run

Update `config/database.yml` with the required config values. Alternatively, set the ENV var `DATABASE_URL`.

`$ ruby exporter.rb`

A CSV will be printed to STDOUT, or an eror raised by the program if there data fails validation checks.
