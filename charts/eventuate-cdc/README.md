# Eventuate CDC chart

This chart installs the [Eventuate CDC service](https://eventuate.io/docs/manual/eventuate-tram/latest/cdc-configuration.html#cdc-configuration), which plays the role of the message relay of the [Transactional Outbox pattern](https://microservices.io/patterns/data/transactional-outbox.html).
It reads messages that have been inserted into a transaction outbox (i.e. MESSAGE table) and publishes them to the message broker.

Note: this chart only supports MySQL and Apache Kafka

See the `values.yaml` to learn how to configure the Eventuate CDC.

