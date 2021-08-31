# useful commands
## build container with no cache
```
docker-compose build --no-cache --progress=plain
```
## open terminal to docker in a NAMESPACE
```
docker-compose exec iris iris session iris -U IRISAPP
```
## clear docker fs
```
docker system prune -f
```

## open SQL shell
```
d $System.SQL.Shell()
```




