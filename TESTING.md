# Testing

The skill was developed test-first: run it, collect failures, turn them into rules, run again. The full log, in Turkish, has the questions Claude asked and the answers given for every trial.

## How results were checked

A result counts as correct only if a check outside the skill's own scripts confirms it:

| Method | Trials |
|---|---|
| Exact comparison with the author's own MATLAB solution | 1, 2, 14 |
| Independent derivation in Python/SymPy, or the agent's functions plugged into the true dynamics and V̇ recomputed | 3, 4, 6–11, 13, and the reruns of 8, 12, 13 |
| Hand check of signs, later confirmed numerically in the reruns | 12 |
| Only the agent's own closed-loop check (the same system was checked independently in trial 4) | 5 |
| Rerun on the user's own MATLAB | 2, 6 (and the law of 2/14 run in Simulink on the full pump model) |

## Trials

| # | Type | Input | Result | Notes |
|---|---|---|---|---|
| 1 | Backstepping | Pump model and V, no step list | Partly passed | Law matches the author's code. Chose V̇'s form and cross-term placement without asking |
| 2 | Backstepping | Pump model, no V | Partly passed | Did not ask about V on its own. When asked, ranked 6 options correctly. Law matches the author's code |
| 3 | Backstepping | Redesign with a barrier Lyapunov function | Passed | Corrected one of its own claims after checking |
| 4 | Backstepping | Real lab system, state equations only, x3² term | Passed | Caught the non-affine x3² term; solved the quadratic and chose the root. Both roots match an independent derivation |
| 5 | Backstepping | Same lab system, full document, reference tracking | Passed | Chose the root from ω > 0. Agent's own check only |
| 6 | Backstepping | u in two equations (not strict-feedback) | Passed | Detected it, used a 2-step design, gave the correct internal-dynamics condition |
| 7 | Backstepping | Step list given, but V in the document is invalid (−½z2²) | Passed | Caught the invalid V; coded both versions and explained the instability |
| 8 | Backstepping | 8 states, u in two equations, 3 hidden errors | Passed | Found all 3 errors. Law has 4308 terms; internal-dynamics condition correct |
| 9 | Backstepping | 5-state chain | Passed | Stated that f1⁽⁴⁾ is needed. 369 terms, matches an independent derivation |
| 10 | Backstepping | State-dependent coefficients, singularity at x1 = −1 | Passed | Asked about the singularity itself; stability region V(0) < ½ |
| 11 | Adaptive | Textbook example ẋ1 = x2, ẋ2 = θx1² + u | Passed | Noted unprompted that θ̂ need not converge to θ |
| 12 | Adaptive | Author's adaptive section (pump, J and L unknown) | Passed | Found 5 document errors and the missing tuning-function term; recommended projection |
| 13 | Adaptive | 3 unknown parameters, one in the first equation | Passed | Said before deriving that plain certainty equivalence is not enough; built full tuning functions |
| 14 | Backstepping | Trial 2's document again, after the skill update | Passed | All 5 behaviours missing in trial 2 fixed. Law matches the author's code |

## Repeatability

Trials 8, 12 and 13 were each run twice more in separate sessions. All 6 runs were correct. Within each pair, the laws were numerically identical:

| Trial | Difference between the two runs' functions (random inputs) | Other check |
|---|---|---|
| 8 | 0 | Both: 3/3 errors found, 4308 terms |
| 12 | 0 | Closed-loop residual V̇ + Σkz² ≈ 1e-13, with the target V̇ between 7 and 258 |
| 13 | ~1e-16 | Simulation identical to the original trial 13 |

Only the form differed between runs: file names, input order, and the length of the generated expression. Check a function's input order before wiring it into Simulink.

## Clean install

The skill was downloaded from this repository and installed as described in the README, under a different Claude account, with all earlier copies of the skill removed. Run on `examples/01_backstepping_pump/input_document.docx`, it produced a `Vin_fun.m` identical to the one in the example: the difference at 5 random points was ≤ 8e-16, and both give v_in = 9.94 V at a physical operating point. Because the example matches the author's reference solution, the fresh run does too.

## What changed after testing

Rules added to the skill from the trials:

- Ask every design choice (V, error sign, cross terms, target V̇) as a separate question.
- Ask the sign assumption before dropping a sign-function term.
- Check that V is positive definite and that the system is in strict-feedback form.
- Adaptive rules: tuning functions, a check that the true θ does not appear in the law, projection.
- Handle polynomial (non-affine) terms.
- Check compact Simulink forms against the full expressions.
- Report the peak control value; use ode15s for stiff systems.
- Log with `evalc` and append to the log, never delete.
- Stop after the document check only if a finding changes the derivation, so there is one question screen.
