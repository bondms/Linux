#!/bin/bash

set -x

set -e
set -o pipefail
set -u

HERE="$(readlink -f "$(dirname "$0")")"
[[ -d "${HERE}" ]] || exit $?

API_KEY=$(gpg --decrypt "${HERE}/api_key.txt.gpg")
POSTCODE=$(gpg --decrypt "${HERE}/postcode.txt.gpg")
ELECTRICITY_MPAN=$(gpg --decrypt "${HERE}/electricity_mpan.txt.gpg")
ELECTRICITY_SERIAL_NUMBER=$(gpg --decrypt "${HERE}/electricity_serial_number.txt.gpg")
ELECTRICITY_PRODUCT=$(gpg --decrypt "${HERE}/electricity_product.txt.gpg")
GAS_MPRN=$(gpg --decrypt "${HERE}/gas_mprn.txt.gpg")
GAS_SERIAL_NUMBER=$(gpg --decrypt "${HERE}/gas_serial_number.txt.gpg")

curl -u "${API_KEY}:" "https://api.octopus.energy/v1/electricity-meter-points/${ELECTRICITY_MPAN}/meters/${ELECTRICITY_SERIAL_NUMBER}/consumption/" > electricity.json || exit $?
curl -u "${API_KEY}:" "https://api.octopus.energy/v1/electricity-meter-points/${ELECTRICITY_MPAN}/meters/${ELECTRICITY_SERIAL_NUMBER}/consumption/?page=2" > electricity_prev1.json || exit $?
curl -u "${API_KEY}:" "https://api.octopus.energy/v1/gas-meter-points/${GAS_MPRN}/meters/${GAS_SERIAL_NUMBER}/consumption/" > gas.json || exit $?
curl -u "${API_KEY}:" "https://api.octopus.energy/v1/products/" > products.json || exit $?
curl -u "${API_KEY}:" "https://api.octopus.energy/v1/products/${ELECTRICITY_PRODUCT}/" > electricity_rates.json || exit $?
curl -u "${API_KEY}:" "https://api.octopus.energy/v1/industry/grid-supply-points/" > gsps.json || exit $?
curl -u "${API_KEY}:" "https://api.octopus.energy/v1/industry/grid-supply-points/?postcode=${POSTCODE}" > gsp.json || exit $?
curl -u "${API_KEY}:" "https://api.octopus.energy/v1/products/${ELECTRICITY_PRODUCT}/electricity-tariffs/E-1R-${ELECTRICITY_PRODUCT}-H/standing-charges/" > go_standing_charges.json || exit $?
curl -u "${API_KEY}:" "https://api.octopus.energy/v1/products/${ELECTRICITY_PRODUCT}/electricity-tariffs/E-1R-${ELECTRICITY_PRODUCT}-H/standard-unit-rates/" > go_standard_unit_rates.json || exit $?
