# 1. Decide which autoscaling method to use.

Date: 3rd July 2019

## Status

Accepted

## Context

We need to decide which aproach we follow with regards to Sync service autoscaling in Kubernetes.
Currently there are two ways to autoscale:

Horizontal Pod Autoscaling: https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/
Vertical Pod Autoscaling: https://cloud.google.com/kubernetes-engine/docs/concepts/verticalpodautoscaler

## Decision

Use HPA as it allows new pods to be created without restarting the existing ones, unlike VPA.
Use HPA as it is more mature and has more documentation available, unlike VPA which is still in beta phase.

## Consequences

Sync service can scale without disrupting existing users.