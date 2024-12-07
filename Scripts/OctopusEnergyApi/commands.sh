#!/bin/bash

# API documentation: https://developer.octopus.energy/docs/api/

set -x

set -e
set -o pipefail
set -u

HERE="$(readlink -e "$(dirname "${BASH_SOURCE[0]}")")"
[[ -d "${HERE}" ]] || exit 1

# If you are an Octopus Energy customer, you can generate an API key from your
# online dashboard (https://octopus.energy/dashboard/developer/).
API_KEY=$(gpg --decrypt "${HERE}/api_key.txt.gpg")
POSTCODE=$(gpg --decrypt "${HERE}/postcode.txt.gpg")

ELECTRICITY_MPAN=$(gpg --decrypt "${HERE}/electricity_mpan.txt.gpg")
ELECTRICITY_SERIAL_NUMBER=$(gpg --decrypt \
    "${HERE}/electricity_serial_number.txt.gpg")
ELECTRICITY_PRODUCT=$(gpg --decrypt "${HERE}/electricity_product.txt.gpg")

GAS_MPRN=$(gpg --decrypt "${HERE}/gas_mprn.txt.gpg")
GAS_SERIAL_NUMBER=$(gpg --decrypt "${HERE}/gas_serial_number.txt.gpg")
GAS_PRODUCT=$(gpg --decrypt "${HERE}/gas_product.txt.gpg")

DATE_STR=$(date +%Y-%m-%d)
DATA_DIR_PATH="${HERE}/data/${DATE_STR}"

BASE_URL="https://api.octopus.energy/"

mkdir --verbose --parents -- "${DATA_DIR_PATH}" || exit 1

curl -u "${API_KEY}:" "${BASE_URL}v1/products/" \
    > "${DATA_DIR_PATH}/products_001.json" || exit 1
for PAGE in {002..999}
do
    curl -u "${API_KEY}:" \
        "${BASE_URL}v1/products/?page=${PAGE}" \
        > "${DATA_DIR_PATH}/products_${PAGE}.json" || exit 1
    if grep -F '{"detail":"Invalid page."}' \
        "${DATA_DIR_PATH}/products_${PAGE}.json"
    then
        break
    fi
done

curl -u "${API_KEY}:" \
    "${BASE_URL}v1/products/${ELECTRICITY_PRODUCT}/" \
    > "${DATA_DIR_PATH}/electricity_product.json" || exit 1
curl -u "${API_KEY}:" "${BASE_URL}v1/products/${GAS_PRODUCT}/" \
    > "${DATA_DIR_PATH}/gas_product.json" || exit 1

curl -u "${API_KEY}:" \
    "${BASE_URL}v1/industry/grid-supply-points/" \
    > "${DATA_DIR_PATH}/gsps.json" || exit 1
curl -u "${API_KEY}:" \
    "${BASE_URL}v1/industry/grid-supply-points/?postcode=${POSTCODE}" \
    > "${DATA_DIR_PATH}/gsp.json" || exit 1

curl -u "${API_KEY}:" \
    "${BASE_URL}v1/products/${ELECTRICITY_PRODUCT}/electricity-tariffs/E-1R-${ELECTRICITY_PRODUCT}-H/standing-charges/" \
    > "${DATA_DIR_PATH}/electricity_standing_charges.json" || exit 1
curl -u "${API_KEY}:" \
    "${BASE_URL}v1/products/${ELECTRICITY_PRODUCT}/electricity-tariffs/E-1R-${ELECTRICITY_PRODUCT}-H/standard-unit-rates/" \
    > "${DATA_DIR_PATH}/electricity_standard_unit_rates.json" || exit 1
curl -u "${API_KEY}:" \
    "${BASE_URL}v1/products/${ELECTRICITY_PRODUCT}/electricity-tariffs/E-1R-${ELECTRICITY_PRODUCT}-H/day-unit-rates/" \
    > "${DATA_DIR_PATH}/electricity_day_standard_unit_rates.json" || exit 1
curl -u "${API_KEY}:" \
    "${BASE_URL}v1/products/${ELECTRICITY_PRODUCT}/electricity-tariffs/E-1R-${ELECTRICITY_PRODUCT}-H/night-unit-rates/" \
    > "${DATA_DIR_PATH}/electricity_night_standard_unit_rates.json" || exit 1

curl -u "${API_KEY}:" \
    "${BASE_URL}v1/products/${GAS_PRODUCT}/gas-tariffs/G-1R-${GAS_PRODUCT}-H/standing-charges/" \
    > "${DATA_DIR_PATH}/gas_standing_charges.json" || exit 1
curl -u "${API_KEY}:" \
    "${BASE_URL}v1/products/${GAS_PRODUCT}/gas-tariffs/G-1R-${GAS_PRODUCT}-H/standard-unit-rates/" \
    > "${DATA_DIR_PATH}/gas_standard_unit_rates.json" || exit 1

curl -u "${API_KEY}:" "${BASE_URL}v1/electricity-meter-points/${ELECTRICITY_MPAN}/meters/${ELECTRICITY_SERIAL_NUMBER}/consumption/" \
    > "${DATA_DIR_PATH}/electricity_001.json" || exit 1
curl -u "${API_KEY}:" "${BASE_URL}v1/gas-meter-points/${GAS_MPRN}/meters/${GAS_SERIAL_NUMBER}/consumption/" \
    > "${DATA_DIR_PATH}/gas_001.json" || exit 1
for PAGE in {002..999}
do
    curl -u "${API_KEY}:" \
        "${BASE_URL}v1/electricity-meter-points/${ELECTRICITY_MPAN}/meters/${ELECTRICITY_SERIAL_NUMBER}/consumption/?page=${PAGE}" \
        > "${DATA_DIR_PATH}/electricity_${PAGE}.json" || exit 1
    curl -u "${API_KEY}:" "${BASE_URL}v1/gas-meter-points/${GAS_MPRN}/meters/${GAS_SERIAL_NUMBER}/consumption/?page=${PAGE}" \
        > "${DATA_DIR_PATH}/gas_${PAGE}.json" || exit 1
done
