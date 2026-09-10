# Credible findings and proportional remediation

The loop closes when every **credible defect** is settled. Theoretical completeness is outside its frame.

A `blocking` or `should-fix` finding establishes all three:

- **Observable harm** — wrong behaviour, regression, material risk, contradiction, consequential ambiguity, or a named requirement or standard breach.
- **Credible trigger** — a supported input, state, environment, or operation; a condition present in the tree; or a plausible maintenance change within the repository's declared architecture.
- **Evidence** — cited code, specification, standards, or repository facts connecting the trigger to the harm.

A fixture or mutation proves reachability only when it models a credible trigger. Rarity is acceptable when impact is high, especially at security, data-integrity, compatibility, or external-input boundaries. Mere logical possibility, an unsupported configuration, or a hypothetical future extension is compatible with a clean review. Route a useful observation below the threshold to `nit`; clean remains terminal and no code change follows.

Remediation is **proportional**: make the smallest clear change that restores the required behaviour for the credible trigger. Prefer removing or simplifying code when that closes the defect. Treat maintainability and comprehensibility as constraints on the repair; added machinery earns its complexity by reducing the demonstrated risk.

On resumed rounds, converge. Re-verify prior findings and inspect the remediation for regressions it could realistically introduce. A genuinely new finding states the new evidence that makes it credible; enumerating progressively more exotic variants of a settled defect class is a speculative spiral, not convergence.
