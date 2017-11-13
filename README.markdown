## Kafka

[![Build Status](https://travis-ci.org/MetaCenterCloudPuppet/cesnet-kafka.svg?branch=master)](https://travis-ci.org/MetaCenterCloudPuppet/cesnet-kafka) [![Puppet Forge](https://img.shields.io/puppetforge/v/cesnet/kafka.svg)](https://forge.puppetlabs.com/cesnet/kafka)

#### Table of Contents

1. [Module Description - What the module does and why it is useful](#module-description)
2. [Setup - The basics of getting started with kafka](#setup)
    * [What cesnet-kafka affects](#what-cesnet-kafka-affects)
    * [Setup requirements](#setup-requirements)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
    * [Module Parameters](#parameters)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Module Description

This module installs and configures Apache Kafka brokers.

It expects list of hostnames, where brokers should be running. Broker IDs will be generated according to the ordering of these hostnames.

Puppet module takes list of the zookeeper servers from zookeeper puppet module.

## Setup

### What cesnet-kafka affects

* Packages: Kafka server package
* Alternatives:
 * alternatives are used for */etc/kafka/conf* in BigTop-based distributions
 * this module switches to the new alternative by default on Debian, so the original configuration can be kept intact
* Files modified:
 * */etc/kafka/conf/server.properties*

### Setup Requirements

There are several known or intended limitations in this module.

Be aware of:

* **Repositories** - no repository is setup, see cesnet-hadoop module Setup Requirements for details

## Usage

**Example 1**: automatic ID assignments

    kafka_brokers = [
      'broker1.example.com',
      'broker2.example.com',
    ]
    zookeeper_hostnames = [
      'zoo1.example.com',
      'zoo2.example.com',
      'zoo3.example.com',
    ]

    node /zoo.\.example'.com/ {
      class{'zookeeper':
        hostnames => $zookeeper_hostnames,
      }
    }

    node /broker.\.example'.com/ {
      class{'kafka':
        hostnames           => $kafka_brokers,
        zookeeper_hostnames => $zookeeper_hostnames,
      }
      include ::kafka::server
    }

**Example 2**: manual ID assignments

    kafka_brokers = [
      'broker1.example.com',
      'broker2.example.com',
    ]
    zookeeper_hostnames = [
      'zoo1.example.com',
      'zoo2.example.com',
      'zoo3.example.com',
    ]

    node /zoo.\.example\.com/ {
      class{'zookeeper':
        hostnames => $zookeeper_hostnames,
      }
    }

    node 'broker1.example.com' {
      class{'kafka':
        id                  => 1,
        zookeeper_hostnames => $zookeeper_hostnames,
      }
      include ::kafka::server
    }

    node 'broker2.example.com' {
      class{'kafka':
        id                  => 2,
        zookeeper_hostnames => $zookeeper_hostnames,
      }
      include ::kafka::server
    }

### IPv6

IPv6 is working out-of-the-box.

But on IPv4-only hosts with enabled IPv6 locally, you may need to set preference to IPv4 though. Everything is working, but there are unusuccessful connection attempts and exceptions in logs.

**IPv4 example without security**:

  class{'kafka':
    ...
    environment => {
      'KAFKA_OPTS' => '-Djava.net.preferIPv4Stack=true',
    }
  }

**IPv4 example with security**:

  class{'kafka':
    realm => ...,
    ...
    environment => {
      'KAFKA_OPTS' => '-Djava.security.auth.login.config=/etc/kafka/conf/jaas.conf -Djava.net.preferIPv4Stack=true',
    }
  }

## Reference

### Classes

* [**`kafka`**](#parameters): Main class
* [**`kafka::server`**]: Kafka broker
* `kafka::server::config`: Configure Kafka broker
* `kafka::server::install`: Installation of Kafka broker
* `kafka::server::service`: Ensure the Kafka broker service is running
* [**`kafka::client`**]: Kafka client
* `kafka::client::config`: Stub class
* `kafka::client::install`: Installation of Kafka client
* `kafka::client::service`: Stub class
* `kafka::params`

### Parameters

####`alternatives`

Switches the alternatives used for the configuration. Default: 'cluster' (Debian) or undef.

It can be used only when supported (for example with distributions based on BigTop).

####`hostnames`

Array of Kafka broker hostnames. Default: undef.

Beware changing leads to changing Kafka broker ID, which requires internal data cleanups or internal metadata modification.

####`id`

ID of Kafka broker. Default: undef (=autodetect).

*id* is the ID number of the Kafka broker. It must be unique number for each broker.

By default, the ID is generated automatically as order of the node hostname (*::fqdn*) in the *hostnames* array.

Beware changing leads requires internal data cleanups or internal metadata modification.

####`properties`

Generic properties to be set for the Kafka brokers. Default: undef.

Some properties are set automatically, "::undef" string explicitly removes given property. Empty string sets the empty value.

####`zookeeper_hostnames`

Hostnames of zookeeper servers. Default: undef (from *zookeeper::hostnames* or 'localhost').

This parameter is not needed, if Kafka broker sits on any of the Zookeeper server node and *zookeeper::hostnames* parameter is used.

## Limitations

No repository is provided. It must be setup externaly, or the Kafka packages must be installed already.

*zookeeper\_hostnames* parameter is a complication and it should not be needed. But that would require refactoring of zookeeper puppet module - to separate zookeeper configuration class from zookeeper server setup.

## Development

* Repository: [https://github.com/MetaCenterCloudPuppet/cesnet-kafka](https://github.com/MetaCenterCloudPuppet/cesnet-kafka)
* Tests:
 * basic: see *.travis.yml*
