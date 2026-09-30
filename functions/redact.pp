# @summary Hide secrets before logging plan data
#
# Replaces the value of any key that names a secret (password, private key,
# licence key, token, secret) with "[redacted]", recursing through hashes and
# arrays. Given tfvars text, redacts the same names in `name = "value"` lines.
# A known_hosts "key" is a public host key and is left alone.
#
# @param data
#   Parameters or tfvars text about to be printed
#
# @return [Variant[Hash, Array, String, Any]] The same data with secrets hidden
function pecdm::redact(Any $data) >> Any {
  $secret = /(?i)(password|private_key|license_key|token|secret)/
  $redacted = $data ? {
    Hash    => $data.map |$k, $v| {
      [$k, ($k =~ $secret) ? { true => '[redacted]', false => pecdm::redact($v) }]
    }.convert_to(Hash),
    Array   => $data.map |$v| { pecdm::redact($v) },
    String  => $data.regsubst(/(?im)^(\s*\w*(password|private_key|license_key|token|secret)\w*\s*=\s*)"[^"]*"/, '\1"[redacted]"', 'G'),
    default => $data,
  }
  $redacted
}
