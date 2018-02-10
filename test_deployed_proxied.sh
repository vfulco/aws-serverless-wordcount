#!/bin/bash
# Exercise the deployed service proxied through the API Gateway

echo "Querying deployment details"
export API_SECRET=$(aws lambda get-function --function-name "ServerlessWordCountProxied" | jq --raw-output '.Configuration.Environment.Variables.ApiSecret')
REST_API_ID=$(aws apigateway get-rest-apis | jq --raw-output '.items[] | select(.name == "serverless-wordcount-stack") | .id')
REST_API_URL="https://${REST_API_ID?}.execute-api.eu-central-1.amazonaws.com/Prod/wordcount"
echo

echo "Creating Authorization header"
API_USER="local"
API_TOKEN_EXPIRES="$(($(date +'%s + 3600')))"
API_TOKEN_DESCRIPTOR="{ \"user\": \"${API_USER?}\", \"expires\": \"${API_TOKEN_EXPIRES?}\" }"
API_AUTHORIZATION_USER=$(echo -n "${API_TOKEN_DESCRIPTOR?}" | base64)
API_AUTHORIZATION_SIGNATURE=$(echo -n "${API_SECRET?}${API_AUTHORIZATION_USER?}" | openssl sha -sha256)
export API_AUTHORIZATION="${API_AUTHORIZATION_USER?}.${API_AUTHORIZATION_SIGNATURE?}"
echo "API_SECRET=\"${API_SECRET?}\""
echo "API_AUTHORIZATION=\"${API_AUTHORIZATION?}\""
echo

echo "API Test healthcheck expect HTTP 200"
AUTHORIZATION_HEADER="Authorization: Bearer ${API_AUTHORIZATION?}"
REST_API_TEST_CMD="curl --include --silent --request GET \"${REST_API_URL?}/health\" --header \"${AUTHORIZATION_HEADER?}\" ; echo"
echo "${REST_API_TEST_CMD?}"
eval "${REST_API_TEST_CMD?}"
echo

echo "API Test with invalid token expect HTTP 401"
AUTHORIZATION_HEADER="Authorization: Bearer ${API_AUTHORIZATION?}FAIL"
REST_API_TEST_CMD="curl --include --silent --request GET \"${REST_API_URL?}/health\" --header \"${AUTHORIZATION_HEADER?}\" ; echo"
echo "${REST_API_TEST_CMD?}"
eval "${REST_API_TEST_CMD?}"
echo

echo "API Test with missing resource HTTP 404"
RESOURCE_KEY="$(uuidgen)"
AUTHORIZATION_HEADER="Authorization: Bearer ${API_AUTHORIZATION?}"
REST_API_TEST_CMD="curl --include --silent --request GET \"${REST_API_URL?}/${RESOURCE_KEY?}\" --header \"${AUTHORIZATION_HEADER?}\" ; echo"
echo "${REST_API_TEST_CMD?}"
eval "${REST_API_TEST_CMD?}"
echo

#echo "Given a PDF containing text"
#aws s3 rm "s3://serverless-wordcount-hopper/" --recursive
#aws s3 rm "s3://serverless-wordcount-result/" --recursive
#aws s3 rm "s3://serverless-wordcount-archive/" --recursive

#echo "API Test annonymous image upload expect HTTP 202"
#FILENAME="polycode.co.uk-mug.jpeg"
#base64 "./${FILENAME?}" > "./${FILENAME?}.base64"
#REST_API_TEST_CMD="curl --include --silent --request POST \"${REST_API_URL?}\" --header \"${AUTHORIZATION_HEADER?}\" --data @\"./${FILENAME?}.base64\" ; echo"
#echo "${REST_API_TEST_CMD?}"
#eval "${REST_API_TEST_CMD?}"

#echo "When the PDF is asynronously sent..."
#FILENAME="ukpga_20100013_en.pdf"
#base64 "./${FILENAME?}" > "./${FILENAME?}.base64"
#REST_API_TEST_CMD="curl --include --silent --request POST \"${REST_API_URL?}\" --header \"${AUTHORIZATION_HEADER?}\" --data @\"./${FILENAME?}.base64\" ; echo"
#echo "${REST_API_TEST_CMD?}"
#eval "${REST_API_TEST_CMD?}" -> get RESULT_KEY from Location header

#echo "We can poll until..."
#echo "Then the PDF is transformed into fragments"
#echo "and the words in the sentence fragments are counted"
#echo "and the results are exported to a configured target folder"
#echo "and the processed pdf is moved to a configured bucket..."
#REST_API_TEST_CMD="curl --include --silent --request GET \"${REST_API_URL?}/${RESULT_KEY?}\" --header \"${AUTHORIZATION_HEADER?}\" --output \"./${FILENAME?}-sync-result.json\" ; echo"
#echo -n "5" ; sleep 1 
#echo -n "." ; sleep 1
#echo -n "." ; sleep 1 
#echo -n "." ; sleep 1
#echo -n "4" ; sleep 1
#echo -n "." ; sleep 1
#echo -n "." ; sleep 1
#echo -n "." ; sleep 1
#echo -n "3" ; sleep 1
#echo -n "." ; sleep 1
#echo -n "." ; sleep 1 
#echo -n "." ; sleep 1
#echo -n "2" ; sleep 1 
#echo -n "." ; sleep 1
#echo -n "." ; sleep 1
#echo -n "." ; sleep 1
#echo -n "1" ; sleep 1
#echo -n "." ; sleep 1
#echo -n "." ; sleep 1
#echo -n "." ; sleep 1 ; echo
#while waiting for result
#   echo "${REST_API_TEST_CMD?}"
#   eval "${REST_API_TEST_CMD?}"
#   pause 5s
#   check
#cat "./${FILENAME?}-sync-result.json" | jq '.' | head -10
#echo "...truncated..."
#cat "./${FILENAME?}-sync-result.json" | jq '.' | tail -10

#echo "When the PDF is synronously sent..."
#FILENAME="ukpga_20100013_en.pdf"
#base64 "./${FILENAME?}" > "./${FILENAME?}.base64"
#REST_API_TEST_CMD="curl --request POST \"${REST_API_URL?}?is_synchronous=true\" --header \"${AUTHORIZATION_HEADER?}\" --data @\"./${FILENAME?}.base64\" --output \"./${FILENAME?}-sync-result.json\" | head -20 ; echo"
#echo "${REST_API_TEST_CMD?}"
#eval "${REST_API_TEST_CMD?}"
#cat "./${FILENAME?}-sync-result.json" | jq '.' | head -10
#echo "...truncated..."
#cat "./${FILENAME?}-sync-result.json" | jq '.' | tail -10
#rm "./${FILENAME?}.base64"
