# Build out restore rake:
# heroku pg:backups:download -a hengage
# pg_restore --verbose --clean --no-acl --no-owner -h localhost -d public latest.dump
# rm latest.dump
