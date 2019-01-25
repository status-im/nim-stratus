docker run -it --rm --device /dev/fuse \
  -v $PWD:/stratus:Z \
  -w /stratus \
  --cap-add SYS_ADMIN \
  a12e/docker-qt:5.12-gcc_64 \
  sh build-in-docker.sh
