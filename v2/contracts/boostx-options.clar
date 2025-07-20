(impl-trait .boostx-options-trait.boostx-options-trait)
(use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-constant NOT-FOUND (err u100))
(define-constant NOT-AUTHORIZED (err u101))
(define-constant INVALID-ADDRESS (err u102))

(define-constant owner tx-sender)

(define-data-var referee (optional uint) none)
(define-data-var sponsor1 (optional uint) none)
(define-data-var sponsor2 (optional uint) none)
(define-data-var sponsor3 (optional uint) none)

(define-data-var storageUri (string-utf8 255) u"")

(define-read-only (get-storage-uri)
    (ok (var-get storageUri))
)
(define-public (update-storage-uri (uri (string-utf8 255)))
    (begin
        (asserts! (is-eq tx-sender owner) NOT-AUTHORIZED)
        (ok (var-set storageUri uri))
    )
)

(define-read-only (construct-options-to-tuple (id uint))
    (let (
            (name (unwrap-panic (contract-call? .bns-v2 get-bns-from-id id)))
            (address (unwrap-panic (contract-call? .bns-v2 get-owner id)))
        )
        {
            id: id,
            name: {
                name: (get name name),
                namespace: (get namespace name),
            },
            address: address,
        }
    )
)
(define-read-only (get-options)
    (let ((royalty-addresses (unwrap! (get-options-ids) NOT-FOUND)))
        (ok (map construct-options-to-tuple royalty-addresses))
    )
)

(define-read-only (get-options-ids)
    (let (
            (referer-bns-id (default-to u0 (var-get referee)))
            (sponsorer1 (default-to u0 (var-get sponsor1)))
            (sponsorer2 (default-to u0 (var-get sponsor2)))
            (sponsorer3 (default-to u0 (var-get sponsor3)))
        )
        (let (
                (append-list-1 (if (> referer-bns-id u0)
                    (list referer-bns-id)
                    (list)
                ))
                (append-list-2 (if (> sponsorer1 u0)
                    (append append-list-1 sponsorer1)
                    append-list-1
                ))
                (append-list-3 (if (> sponsorer2 u0)
                    (append append-list-2 sponsorer2)
                    append-list-2
                ))
                (append-list-final (if (> sponsorer3 u0)
                    (append append-list-3 sponsorer3)
                    append-list-3
                ))
            )
            (ok append-list-final)
        )
    )
)

(define-private (validate-id
        (id uint)
        (res bool)
    )
    (let (
            (id-owner (unwrap! (unwrap! (contract-call? .bns-v2 get-owner id) false) false))
            ;; Returns the BNS-V2 ID's princpal
        )
        (asserts! (is-standard id-owner) false)
        true
    )
)

(define-public (update-sponsor (sponsors (list 3 uint)))
    (begin
        ;; Proceed to update sponsor vars
        (if (is-eq (len sponsors) u3)
            (begin
                ;; Validate all sponsor IDs
                (asserts! (fold validate-id sponsors true) INVALID-ADDRESS)
                (var-set sponsor1 (element-at? sponsors u0))
                (var-set sponsor2 (element-at? sponsors u1))
                (var-set sponsor3 (element-at? sponsors u2))
                (ok true)
            )
            (if (is-eq (len sponsors) u2)
                (begin
                    (var-set sponsor1 (element-at? sponsors u0))
                    (var-set sponsor2 (element-at? sponsors u1))
                    (ok true)
                )
                (if (is-eq (len sponsors) u1)
                    (begin
                        (var-set sponsor1 (element-at? sponsors u0))
                        (ok true)
                    )
                    (ok false)
                )
            )
        )
    )
)

(define-public (set-referee (ref-id (optional uint)))
    (let (
            (id (unwrap! ref-id NOT-FOUND))
            (id-owner (unwrap! (unwrap! (contract-call? .bns-v2 get-owner id) NOT-FOUND)
                NOT-FOUND
            ))
            ;; Returns the BNS-V2 ID's princpal
        )
        (asserts! (is-eq tx-sender owner) NOT-AUTHORIZED)
        (asserts! (is-standard id-owner) INVALID-ADDRESS)
        ;; This validates the ID has a valid princpal address
        (if (is-none (var-get referee))
            (ok (var-set referee ref-id))
            (ok false)
        )
    )
)
