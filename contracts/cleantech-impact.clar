(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-PROJECT-NOT-FOUND (err u101))
(define-constant ERR-INVALID-AMOUNT (err u102))
(define-constant ERR-INSUFFICIENT-CREDITS (err u103))
(define-constant ERR-PROJECT-NOT-VERIFIED (err u104))
(define-constant ERR-ALREADY-VERIFIED (err u105))
(define-constant ERR-USER-NOT-FOUND (err u106))
(define-constant ERR-INVALID-CATEGORY (err u107))
(define-constant ERR-MEASUREMENT-NOT-FOUND (err u108))
(define-constant ERR-INVALID-DATA (err u109))

(define-data-var contract-owner principal tx-sender)
(define-data-var total-carbon-offset uint u0)
(define-data-var total-projects uint u0)
(define-data-var verification-threshold uint u3)
(define-data-var platform-fee-rate uint u200)

(define-map users principal {
    carbon-credits: uint,
    projects-created: uint,
    total-impact-score: uint,
    verification-power: uint,
    joined-at: uint,
    reputation: uint
})

(define-map projects uint {
    creator: principal,
    name: (string-ascii 100),
    category: (string-ascii 50),
    description: (string-ascii 500),
    target-impact: uint,
    current-impact: uint,
    carbon-credits-issued: uint,
    verification-count: uint,
    verified: bool,
    created-at: uint,
    status: (string-ascii 20)
})

(define-map project-verifications { project-id: uint, verifier: principal } {
    verified-at: uint,
    impact-confirmed: uint,
    verification-note: (string-ascii 200)
})

(define-map impact-measurements uint {
    project-id: uint,
    measurer: principal,
    measurement-type: (string-ascii 50),
    value: uint,
    unit: (string-ascii 20),
    timestamp: uint,
    verified: bool
})

(define-map carbon-transactions uint {
    from: principal,
    to: principal,
    amount: uint,
    price: uint,
    project-id: uint,
    transaction-type: (string-ascii 20),
    timestamp: uint
})

(define-map technology-categories (string-ascii 50) {
    total-projects: uint,
    total-impact: uint,
    average-success-rate: uint
})

(define-data-var next-project-id uint u1)
(define-data-var next-measurement-id uint u1)
(define-data-var next-transaction-id uint u1)

(define-public (register-user (verification-power uint))
    (let ((caller tx-sender))
        (if (is-some (map-get? users caller))
            (err u100)
            (begin
                (map-set users caller {
                    carbon-credits: u0,
                    projects-created: u0,
                    total-impact-score: u0,
                    verification-power: verification-power,
                    joined-at: stacks-block-height,
                    reputation: u100
                })
                (ok true)))))

(define-public (create-project (name (string-ascii 100)) (category (string-ascii 50)) (description (string-ascii 500)) (target-impact uint))
    (let ((project-id (var-get next-project-id))
          (caller tx-sender)
          (user-data (unwrap! (map-get? users caller) ERR-USER-NOT-FOUND)))
        (if (< target-impact u1)
            ERR-INVALID-AMOUNT
            (begin
                (map-set projects project-id {
                    creator: caller,
                    name: name,
                    category: category,
                    description: description,
                    target-impact: target-impact,
                    current-impact: u0,
                    carbon-credits-issued: u0,
                    verification-count: u0,
                    verified: false,
                    created-at: stacks-block-height,
                    status: "active"
                })
                (map-set users caller {
                    carbon-credits: (get carbon-credits user-data),
                    projects-created: (+ (get projects-created user-data) u1),
                    total-impact-score: (get total-impact-score user-data),
                    verification-power: (get verification-power user-data),
                    joined-at: (get joined-at user-data),
                    reputation: (+ (get reputation user-data) u5)
                })
                (var-set total-projects (+ (var-get total-projects) u1))
                (var-set next-project-id (+ project-id u1))
                (ok project-id)))))

(define-public (record-impact-measurement (project-id uint) (measurement-type (string-ascii 50)) (value uint) (unit (string-ascii 20)))
    (let ((measurement-id (var-get next-measurement-id))
          (caller tx-sender)
          (project-data (unwrap! (map-get? projects project-id) ERR-PROJECT-NOT-FOUND)))
        (if (not (is-eq caller (get creator project-data)))
            ERR-NOT-AUTHORIZED
            (if (< value u1)
                ERR-INVALID-AMOUNT
                (begin
                    (map-set impact-measurements measurement-id {
                        project-id: project-id,
                        measurer: caller,
                        measurement-type: measurement-type,
                        value: value,
                        unit: unit,
                        timestamp: stacks-block-height,
                        verified: false
                    })
                    (var-set next-measurement-id (+ measurement-id u1))
                    (ok measurement-id))))))

(define-public (verify-project (project-id uint) (impact-confirmed uint) (verification-note (string-ascii 200)))
    (let ((caller tx-sender)
          (project-data (unwrap! (map-get? projects project-id) ERR-PROJECT-NOT-FOUND))
          (user-data (unwrap! (map-get? users caller) ERR-USER-NOT-FOUND)))
        (if (< (get verification-power user-data) u1)
            ERR-NOT-AUTHORIZED
            (if (is-some (map-get? project-verifications { project-id: project-id, verifier: caller }))
                ERR-ALREADY-VERIFIED
                (let ((new-verification-count (+ (get verification-count project-data) u1)))
                    (map-set project-verifications { project-id: project-id, verifier: caller } {
                        verified-at: stacks-block-height,
                        impact-confirmed: impact-confirmed,
                        verification-note: verification-note
                    })
                    (map-set projects project-id {
                        creator: (get creator project-data),
                        name: (get name project-data),
                        category: (get category project-data),
                        description: (get description project-data),
                        target-impact: (get target-impact project-data),
                        current-impact: (+ (get current-impact project-data) impact-confirmed),
                        carbon-credits-issued: (get carbon-credits-issued project-data),
                        verification-count: new-verification-count,
                        verified: (>= new-verification-count (var-get verification-threshold)),
                        created-at: (get created-at project-data),
                        status: (get status project-data)
                    })
                    (map-set users caller {
                        carbon-credits: (get carbon-credits user-data),
                        projects-created: (get projects-created user-data),
                        total-impact-score: (get total-impact-score user-data),
                        verification-power: (get verification-power user-data),
                        joined-at: (get joined-at user-data),
                        reputation: (+ (get reputation user-data) u3)
                    })
                    (ok new-verification-count))))))

(define-public (issue-carbon-credits (project-id uint) (amount uint))
    (let ((caller tx-sender)
          (project-data (unwrap! (map-get? projects project-id) ERR-PROJECT-NOT-FOUND))
          (creator-data (unwrap! (map-get? users (get creator project-data)) ERR-USER-NOT-FOUND)))
        (if (not (is-eq caller (var-get contract-owner)))
            ERR-NOT-AUTHORIZED
            (if (not (get verified project-data))
                ERR-PROJECT-NOT-VERIFIED
                (if (< amount u1)
                    ERR-INVALID-AMOUNT
                    (let ((platform-fee (/ (* amount (var-get platform-fee-rate)) u10000))
                          (creator-credits (- amount platform-fee)))
                        (map-set users (get creator project-data) {
                            carbon-credits: (+ (get carbon-credits creator-data) creator-credits),
                            projects-created: (get projects-created creator-data),
                            total-impact-score: (+ (get total-impact-score creator-data) amount),
                            verification-power: (get verification-power creator-data),
                            joined-at: (get joined-at creator-data),
                            reputation: (+ (get reputation creator-data) u10)
                        })
                        (map-set projects project-id {
                            creator: (get creator project-data),
                            name: (get name project-data),
                            category: (get category project-data),
                            description: (get description project-data),
                            target-impact: (get target-impact project-data),
                            current-impact: (get current-impact project-data),
                            carbon-credits-issued: (+ (get carbon-credits-issued project-data) amount),
                            verification-count: (get verification-count project-data),
                            verified: (get verified project-data),
                            created-at: (get created-at project-data),
                            status: (get status project-data)
                        })
                        (var-set total-carbon-offset (+ (var-get total-carbon-offset) amount))
                        (ok creator-credits)))))))

(define-public (transfer-carbon-credits (recipient principal) (amount uint))
    (let ((caller tx-sender)
          (sender-data (unwrap! (map-get? users caller) ERR-USER-NOT-FOUND))
          (recipient-data (unwrap! (map-get? users recipient) ERR-USER-NOT-FOUND))
          (transaction-id (var-get next-transaction-id)))
        (if (< amount u1)
            ERR-INVALID-AMOUNT
            (if (< (get carbon-credits sender-data) amount)
                ERR-INSUFFICIENT-CREDITS
                (begin
                    (map-set users caller {
                        carbon-credits: (- (get carbon-credits sender-data) amount),
                        projects-created: (get projects-created sender-data),
                        total-impact-score: (get total-impact-score sender-data),
                        verification-power: (get verification-power sender-data),
                        joined-at: (get joined-at sender-data),
                        reputation: (get reputation sender-data)
                    })
                    (map-set users recipient {
                        carbon-credits: (+ (get carbon-credits recipient-data) amount),
                        projects-created: (get projects-created recipient-data),
                        total-impact-score: (get total-impact-score recipient-data),
                        verification-power: (get verification-power recipient-data),
                        joined-at: (get joined-at recipient-data),
                        reputation: (+ (get reputation recipient-data) u1)
                    })
                    (map-set carbon-transactions transaction-id {
                        from: caller,
                        to: recipient,
                        amount: amount,
                        price: u0,
                        project-id: u0,
                        transaction-type: "transfer",
                        timestamp: stacks-block-height
                    })
                    (var-set next-transaction-id (+ transaction-id u1))
                    (ok transaction-id))))))

(define-public (purchase-carbon-credits (seller principal) (amount uint) (price uint))
    (let ((caller tx-sender)
          (seller-data (unwrap! (map-get? users seller) ERR-USER-NOT-FOUND))
          (buyer-data (unwrap! (map-get? users caller) ERR-USER-NOT-FOUND))
          (transaction-id (var-get next-transaction-id)))
        (if (< amount u1)
            ERR-INVALID-AMOUNT
            (if (< (get carbon-credits seller-data) amount)
                ERR-INSUFFICIENT-CREDITS
                (begin
                    (map-set users seller {
                        carbon-credits: (- (get carbon-credits seller-data) amount),
                        projects-created: (get projects-created seller-data),
                        total-impact-score: (get total-impact-score seller-data),
                        verification-power: (get verification-power seller-data),
                        joined-at: (get joined-at seller-data),
                        reputation: (+ (get reputation seller-data) u2)
                    })
                    (map-set users caller {
                        carbon-credits: (+ (get carbon-credits buyer-data) amount),
                        projects-created: (get projects-created buyer-data),
                        total-impact-score: (get total-impact-score buyer-data),
                        verification-power: (get verification-power buyer-data),
                        joined-at: (get joined-at buyer-data),
                        reputation: (+ (get reputation buyer-data) u1)
                    })
                    (map-set carbon-transactions transaction-id {
                        from: seller,
                        to: caller,
                        amount: amount,
                        price: price,
                        project-id: u0,
                        transaction-type: "purchase",
                        timestamp: stacks-block-height
                    })
                    (var-set next-transaction-id (+ transaction-id u1))
                    (ok transaction-id))))))

(define-public (retire-carbon-credits (amount uint) (project-id uint))
    (let ((caller tx-sender)
          (user-data (unwrap! (map-get? users caller) ERR-USER-NOT-FOUND))
          (project-data (unwrap! (map-get? projects project-id) ERR-PROJECT-NOT-FOUND))
          (transaction-id (var-get next-transaction-id)))
        (if (< amount u1)
            ERR-INVALID-AMOUNT
            (if (< (get carbon-credits user-data) amount)
                ERR-INSUFFICIENT-CREDITS
                (begin
                    (map-set users caller {
                        carbon-credits: (- (get carbon-credits user-data) amount),
                        projects-created: (get projects-created user-data),
                        total-impact-score: (+ (get total-impact-score user-data) (* amount u2)),
                        verification-power: (get verification-power user-data),
                        joined-at: (get joined-at user-data),
                        reputation: (+ (get reputation user-data) u5)
                    })
                    (map-set carbon-transactions transaction-id {
                        from: caller,
                        to: caller,
                        amount: amount,
                        price: u0,
                        project-id: project-id,
                        transaction-type: "retirement",
                        timestamp: stacks-block-height
                    })
                    (var-set next-transaction-id (+ transaction-id u1))
                    (ok transaction-id))))))

(define-public (update-project-status (project-id uint) (new-status (string-ascii 20)))
    (let ((caller tx-sender)
          (project-data (unwrap! (map-get? projects project-id) ERR-PROJECT-NOT-FOUND)))
        (if (not (is-eq caller (get creator project-data)))
            ERR-NOT-AUTHORIZED
            (begin
                (map-set projects project-id {
                    creator: (get creator project-data),
                    name: (get name project-data),
                    category: (get category project-data),
                    description: (get description project-data),
                    target-impact: (get target-impact project-data),
                    current-impact: (get current-impact project-data),
                    carbon-credits-issued: (get carbon-credits-issued project-data),
                    verification-count: (get verification-count project-data),
                    verified: (get verified project-data),
                    created-at: (get created-at project-data),
                    status: new-status
                })
                (ok true)))))

(define-read-only (get-user-data (user principal))
    (map-get? users user))

(define-read-only (get-project-data (project-id uint))
    (map-get? projects project-id))

(define-read-only (get-measurement-data (measurement-id uint))
    (map-get? impact-measurements measurement-id))

(define-read-only (get-transaction-data (transaction-id uint))
    (map-get? carbon-transactions transaction-id))

(define-read-only (get-project-verification (project-id uint) (verifier principal))
    (map-get? project-verifications { project-id: project-id, verifier: verifier }))

(define-read-only (get-platform-stats)
    {
        total-carbon-offset: (var-get total-carbon-offset),
        total-projects: (var-get total-projects),
        verification-threshold: (var-get verification-threshold),
        platform-fee-rate: (var-get platform-fee-rate),
        next-project-id: (var-get next-project-id),
        next-measurement-id: (var-get next-measurement-id),
        next-transaction-id: (var-get next-transaction-id)
    })

(define-read-only (calculate-impact-efficiency (project-id uint))
    (let ((project-data (unwrap! (map-get? projects project-id) (err u0))))
        (if (> (get target-impact project-data) u0)
            (ok (/ (* (get current-impact project-data) u100) (get target-impact project-data)))
            (ok u0))))

(define-read-only (get-user-carbon-balance (user principal))
    (match (map-get? users user)
        user-data (ok (get carbon-credits user-data))
        ERR-USER-NOT-FOUND))

(define-public (update-verification-threshold (new-threshold uint))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
        (asserts! (> new-threshold u0) ERR-INVALID-AMOUNT)
        (var-set verification-threshold new-threshold)
        (ok true)))

(define-public (update-platform-fee (new-rate uint))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
        (asserts! (<= new-rate u1000) ERR-INVALID-AMOUNT)
        (var-set platform-fee-rate new-rate)
        (ok true)))