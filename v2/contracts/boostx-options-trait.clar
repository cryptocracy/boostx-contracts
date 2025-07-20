(define-trait boostx-options-trait (   
    (get-storage-uri
        ()
        (response (string-utf8 255) (string-utf8 0))
    )
    (set-referee
        ((optional uint))
        (response bool uint)
    )
    (update-sponsor
        ((list 3 uint))
        (response bool uint)
    )
    (get-options-ids
        ()
        (response (list 4 uint) (list 0 uint))
    )
))
