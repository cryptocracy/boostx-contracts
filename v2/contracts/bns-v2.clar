(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))

(define-non-fungible-token stacksies uint)

(define-data-var last-token-id uint u0)

;; (new) Define a map to link NFT IDs to their respective names and namespaces.
(define-map index-to-name
    uint
    {
        name: (buff 48),
        namespace: (buff 20),
    }
)

(define-public (buy-name
        (name (buff 48))
        (namespace (buff 20))
        (buyer principal)
    )
    (let ((token-id (+ (var-get last-token-id) u1)))
        (map-set index-to-name token-id {
            name: name,
            namespace: namespace,
        })
        (mint buyer)
    )
)

(define-read-only (get-bns-from-id (id uint))
    ;; Attempts to retrieve the name and namespace from the 'index-to-name' map using the provided id as the key.
    (map-get? index-to-name id)
)

(define-read-only (get-last-token-id)
    (ok (var-get last-token-id))
)

(define-read-only (get-token-uri (token-id uint))
    (ok none)
)

(define-read-only (get-owner (token-id uint))
    (ok (nft-get-owner? stacksies token-id))
)

(define-public (transfer
        (token-id uint)
        (sender principal)
        (recipient principal)
    )
    (begin
        (asserts! (is-eq tx-sender sender) err-not-token-owner)
        (nft-transfer? stacksies token-id sender recipient)
    )
)

(define-public (mint (recipient principal))
    (let ((token-id (+ (var-get last-token-id) u1)))
        ;; (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (try! (nft-mint? stacksies token-id recipient))
        (var-set last-token-id token-id)
        (ok token-id)
    )
)