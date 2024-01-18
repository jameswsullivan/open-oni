# Open ONI (Customized)

## Original Project

- This repo is forked from the [open-oni](https://github.com/open-oni/open-oni) project.
- See the [original readme here](https://github.com/open-oni/open-oni/blob/dev/README.md)
- [Customizations](https://github.com/jameswsullivan/open-oni/blob/customizations/CUSTOMIZATIONS.md)

- The `manager` service has to be started first for necessary files to be copied into the `/opt/openoni` folder before the `web` service can successfully start.

## Run Open ONI with `docker compose`

**Start Instance**
```
docker compose up -d
```

**Stop Instance**
```
docker compose down
or
docker compose down -v
```

**Auto load batches**
```
docker exec -it openoni-web bash
cd /opt/openoni
source ENV/bin/activate
./batch_load_batches.sh
```

**Compile Themes**
```
docker exec -it openoni-web bash
cd /opt/openoni
./compile_themes.sh
```

## Contact
I'm in the Open ONI Slack Channel.