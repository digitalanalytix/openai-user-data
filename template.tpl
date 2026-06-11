___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "MACRO",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "OpenAI - User Data",
  "categories": [
    "UTILITY",
    "ADVERTISING",
    "CONVERSIONS"
  ],
  "brand": {
    "id": "brand_digitalanalytix",
    "displayName": "DigitalAnalytix"
  },
  "description": "Builds and validates the OpenAI user data object (email_sha256, external_id_sha256, country, city, zip_code) for identity matching. Acts as a PII guard: values that are not valid SHA-256 hashes are dropped instead of being sent raw.",
  "containerContexts": [
    "WEB"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "emailSha256",
    "displayName": "Email (SHA-256 hashed)",
    "simpleValueType": true,
    "help": "SHA-256 hash of the trimmed, lowercase email. Must be a 64-character hexadecimal string. Raw emails are dropped, never forwarded."
  },
  {
    "type": "TEXT",
    "name": "externalIdSha256",
    "displayName": "External ID (SHA-256 hashed)",
    "simpleValueType": true,
    "help": "SHA-256 hash of a stable customer identifier. Must be a 64-character hexadecimal string. Raw IDs are dropped, never forwarded."
  },
  {
    "type": "TEXT",
    "name": "country",
    "displayName": "Country",
    "simpleValueType": true,
    "help": "Two-letter ISO 3166-1 country code (e.g. US, GB, DE). Trimmed and uppercased automatically."
  },
  {
    "type": "TEXT",
    "name": "city",
    "displayName": "City",
    "simpleValueType": true,
    "help": "City name. Trimmed, lowercased, and truncated to 128 characters automatically."
  },
  {
    "type": "TEXT",
    "name": "zipCode",
    "displayName": "Zip Code",
    "simpleValueType": true,
    "help": "Postal/zip code. Trimmed and truncated to 32 characters automatically."
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

const makeString = require('makeString');
const Object = require('Object');
const log = require('logToConsole');

const user = {};

if (data.emailSha256) {
  const email = makeString(data.emailSha256).trim().toLowerCase();
  if (isSha256Hex(email)) {
    user.email_sha256 = email;
  } else {
    log('OpenAI User Data: email value is not a valid SHA-256 hash — dropped to prevent sending raw PII.');
  }
}

if (data.externalIdSha256) {
  const extId = makeString(data.externalIdSha256).trim().toLowerCase();
  if (isSha256Hex(extId)) {
    user.external_id_sha256 = extId;
  } else {
    log('OpenAI User Data: external ID value is not a valid SHA-256 hash — dropped to prevent sending raw PII.');
  }
}

if (data.country) {
  const country = makeString(data.country).trim().toUpperCase();
  if (country.length === 2) {
    user.country = country;
  } else {
    log('OpenAI User Data: country must be a two-letter ISO 3166-1 code — dropped.');
  }
}

if (data.city) {
  user.city = makeString(data.city).trim().toLowerCase().substring(0, 128);
}

if (data.zipCode) {
  user.zip_code = makeString(data.zipCode).trim().substring(0, 32);
}

if (Object.keys(user).length === 0) {
  return undefined;
}

return user;

function isSha256Hex(value) {
  if (!value || value.length !== 64) {
    return false;
  }
  const hex = '0123456789abcdef';
  for (let i = 0; i < value.length; i++) {
    if (hex.indexOf(value.charAt(i)) === -1) {
      return false;
    }
  }
  return true;
}


___WEB_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___TESTS___

scenarios:
- name: Builds user object from valid inputs
  code: |-
    const hash = 'a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2';

    const result = runCode({
      emailSha256: hash,
      country: 'us',
      city: '  New York ',
      zipCode: ' 10001 '
    });

    assertThat(result.email_sha256).isEqualTo(hash);
    assertThat(result.country).isEqualTo('US');
    assertThat(result.city).isEqualTo('new york');
    assertThat(result.zip_code).isEqualTo('10001');
- name: Drops raw email instead of forwarding PII
  code: |-
    const result = runCode({
      emailSha256: 'someone@example.com',
      country: 'US'
    });

    assertThat(result.email_sha256).isUndefined();
    assertThat(result.country).isEqualTo('US');
- name: Normalizes uppercase hash to lowercase
  code: |-
    const upper = 'A1B2C3D4E5F6A1B2C3D4E5F6A1B2C3D4E5F6A1B2C3D4E5F6A1B2C3D4E5F6A1B2';
    const lower = 'a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2';

    const result = runCode({ externalIdSha256: upper });

    assertThat(result.external_id_sha256).isEqualTo(lower);
- name: Drops invalid country code
  code: |-
    const result = runCode({
      country: 'USA',
      city: 'Boston'
    });

    assertThat(result.country).isUndefined();
    assertThat(result.city).isEqualTo('boston');
- name: Returns undefined when no valid fields
  code: |-
    const result = runCode({});

    assertThat(result).isUndefined();


___NOTES___

OpenAI user data builder and PII guard. Validates SHA-256 hashes and
normalizes geo fields per the OpenAI Measurement Pixel specification.