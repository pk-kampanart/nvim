(heredoc_redirect
  redirect:
    (file_redirect
     destination: (word) @injection.filename)
  (heredoc_body) @injection.content)

(heredoc_redirect
  (comment) @injection.language
  (heredoc_body) @injection.content
  (#set! @injection.language "priority" 150)
  (#gsub! @injection.language "^.*ft=(.*)$" "%1"))
