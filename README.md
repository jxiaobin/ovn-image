1. create build env

  `docker buildx create --name ovn --platform linux/amd64,linux/arm64 --use --driver docker-container`

   run following if image build ends up with some file not found error:

   ```
   docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
   docker buildx inspect --bootstrap
   ```
2. build for amd64

  `docker buildx build . -o type=docker -t jxiaobin/ovn-amd64:385aedb --platform linux/amd64`

3. build for arm64

  `docker buildx build . -o type=docker -t jxiaobin/ovn-arm64:385aedb --platform linux/arm64`

4. create manifest
   ```
   docker push jxiaobin/ovn-amd64:385aedb
   docker push jxiaobin/ovn-arm64:385aedb
   docker manifest create jxiaobin/ovn:385aedb --amend jxiaobin/ovn-amd64:385aedb --amend jxiaobin/ovn-arm64:385aedb 
   docker manifest push jxiaobin/ovn:385aedb
   ```

5. run ovn-host

   `docker run -v /var/run/openvswitch:/var/run/openvswitch -v /var/lib/openvswitch:/var/lib/openvswitch --name ovn-controller -d fb860f9782a0 /usr/bin/ovn-controller unix:/var/run/openvswitch/db.sock`


6. run ovn-central

   ```
   docker volume create ovn-config
   docker volume create ovs-config
   docker volume create ovs-state
   docker volume create ovn-state
   docker run --mount source=ovs-config,target=/etc/openvswitch --mount source=ovn-config,target=/etc/ovn --mount source=ovn-state,target=/var/lib/ovn --mount source=ovs-state,target=/var/lib/openvswitch -p 6641:6641 -p 6642:6642 -d ovn:385aedb /usr/local/bin/start.sh
   ```
