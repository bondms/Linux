#!/bin/bash

# API documentation: https://developer.octopus.energy/docs/api/

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

DATE_STR=$(date +%Y-%m-%d)
DATA_DIR_PATH="${HERE}/data/${DATE_STR}"
mkdir -- "${DATA_DIR_PATH}" || exit $?

curl -u "${API_KEY}:" "https://api.octopus.energy/v1/products/" > "${DATA_DIR_PATH}/products.json" || exit $?
curl -u "${API_KEY}:" "https://api.octopus.energy/v1/products/${ELECTRICITY_PRODUCT}/" > "${DATA_DIR_PATH}/electricity_rates.json" || exit $?
curl -u "${API_KEY}:" "https://api.octopus.energy/v1/industry/grid-supply-points/" > "${DATA_DIR_PATH}/gsps.json" || exit $?
curl -u "${API_KEY}:" "https://api.octopus.energy/v1/industry/grid-supply-points/?postcode=${POSTCODE}" > "${DATA_DIR_PATH}/gsp.json" || exit $?
curl -u "${API_KEY}:" "https://api.octopus.energy/v1/products/${ELECTRICITY_PRODUCT}/electricity-tariffs/E-1R-${ELECTRICITY_PRODUCT}-H/standing-charges/" > "${DATA_DIR_PATH}/go_standing_charges.json" || exit $?
curl -u "${API_KEY}:" "https://api.octopus.energy/v1/products/${ELECTRICITY_PRODUCT}/electricity-tariffs/E-1R-${ELECTRICITY_PRODUCT}-H/standard-unit-rates/" > "${DATA_DIR_PATH}/go_standard_unit_rates.json" || exit $?

curl -u "${API_KEY}:" "https://api.octopus.energy/v1/electricity-meter-points/${ELECTRICITY_MPAN}/meters/${ELECTRICITY_SERIAL_NUMBER}/consumption/" > "${DATA_DIR_PATH}/electricity_001.json" || exit $?
curl -u "${API_KEY}:" "https://api.octopus.energy/v1/gas-meter-points/${GAS_MPRN}/meters/${GAS_SERIAL_NUMBER}/consumption/" > "${DATA_DIR_PATH}/gas_001.json" || exit $?

for PAGE in {002..999}
do
    curl -u "${API_KEY}:" "https://api.octopus.energy/v1/electricity-meter-points/${ELECTRICITY_MPAN}/meters/${ELECTRICITY_SERIAL_NUMBER}/consumption/?page=${PAGE}" > "${DATA_DIR_PATH}/electricity_${PAGE}.json" || exit $?
    curl -u "${API_KEY}:" "https://api.octopus.energy/v1/gas-meter-points/${GAS_MPRN}/meters/${GAS_SERIAL_NUMBER}/consumption/?page=${PAGE}" > "${DATA_DIR_PATH}/gas_${PAGE}.json" || exit $?
done
