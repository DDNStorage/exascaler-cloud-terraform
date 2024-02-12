#!/usr/bin/env bash
# Copyright (c) 2024 DataDirect Networks, Inc.
# All Rights Reserved.

set +o xtrace
set -o nounset
set -o errexit
set -o pipefail
set -o noglob

export LC_ALL=C LANG=C

typeset -a options=(config count deployment project timeout waiter zone)
typeset -r gcloud=$(type -fP gcloud || true)
typeset -r config="${config:-}"
typeset -r count="${count:-}"
typeset -r debug="${debug:-}"
typeset -r deployment="${deployment:-}"
typeset -r project="${project:-}"
typeset -r timeout="${timeout:-}"
typeset -r waiter="${waiter:-}"
typeset -r zone="${zone:-}"
typeset option

if [[ -z "$gcloud" ]]; then
	cat <<-EOF

	ERROR: gcloud command not found.

	Your operating system must be able to run Google Cloud SDK commands.

	Get the latest version of Google Cloud SDK:

	https://cloud.google.com/sdk/docs/install

	EOF

	exit 1
fi

for option in "${options[@]}"; do
	if [[ -z "${!option:-}" ]]; then
		cat <<-EOF

		ERROR: environment variable $option not found.

		EOF

		exit 1
	fi
done

if [[ -n "$debug" ]]; then
	set -o xtrace
fi

$gcloud beta runtime-config \
	configs variables list \
	--project="$project" \
	--config-name="$config" \
	--values

$gcloud beta runtime-config \
	configs waiters list \
	--project="$project" \
	--config-name="$config" \
	--format='value(name)' | \
xargs -L 1 -I % -r -t gcloud beta \
	runtime-config configs \
	waiters delete % \
	--project="$project" \
	--config-name="$config"

$gcloud beta runtime-config \
	configs waiters create "$waiter" \
	--project="$project" \
	--config-name="$config" \
	--success-cardinality-path=success \
	--success-cardinality-number="$count" \
	--failure-cardinality-path=failure \
	--failure-cardinality-number=1 \
	--timeout="$timeout"

exit 0
