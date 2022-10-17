#! /bin/bash -e

cat > generated_config.yml <<END
version: 2.1
orbs:
  test-chart:
    jobs:
      test-chart:
        parameters:
          script:
            description: the script to execute
            type: string
    machine:
      image: ubuntu-2004:202101-01
    steps:
      - add_ssh_keys:
          fingerprints:
            - "0a:2e:d8:65:0d:6f:70:5b:1e:a1:45:70:5f:8a:72:e6"
      - checkout
      - run: sudo ./install-k8s-tools.sh
      - run: kind create cluster
      - run: <<parameters.script>>     
workflows:
  version: 2.1
  build-test-and-deploy:
END

for build_script in test-*.sh ; do
cat >> generated_config.yml <<END
      - test-chart/test-chart:
          name: $build_script
          script: ./$build_script
END
done

cat >> generated_config.yml <<END
      - test-chart/test-chart:
          name: publish
          script: ./.circleci/circleci-publish-charts.sh   
          requires:
END

for build_script in test-*.sh ; do
cat >> generated_config.yml <<END
            - $build_script
END
done
