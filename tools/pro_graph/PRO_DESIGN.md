# PRO story graph design (skeleton)

Skeleton for review: only the six tone-check scenes are written (`tools/authoring/work/pro_tone_check.json`, not imported); nothing is generated into the game data. Source: `pro_design.json` (regenerate this file with `make_pro_design_md.py`). Scoping and engine facts: `PRO_SCOPING.md`.

**Timing.** The game has no pro season count, so scenes gate on **age** and on **seasons with the current club** (the count restarts at every new club). Kinds:
- **once**: one time per career.
- **variant**: one of an age-banded set (rookie, prime, veteran).
- **repeat**: re-fires on its trigger, with a 15-week cooldown.

**Waits on** the consolidated gameplay request:
- R1: no age cap (open)
- R3: savings + money field (open)
- R4: transition flags + right-now metrics (landed: slump_now, benched_now, injured_now, fg_streak, season_fg_pct, pro_seasons, contract_years_left, clubs; flags contract_year, re_signed, released, signed_new_club)
- R5: {club} / {town} (landed)
- R6: once_per_club (landed)
- R7: season-end dismissal: set dismissed (landed)
- R8: recast {love_interest} (open)
- R9: longer pro suspensions (open)

R2 changes numbers only; no scene waits on it. Money scenes (R3) are written now with flags and stress costs and get `money` values later.

**Pro strike flags** (the team-discipline steps PRO_124-128 read and clear only these): `stayed_out_pro`, `pro_night_out`, `pro_unapproved_supplement`, `pro_bar_fight`, `pro_shared_inside_info`, `pro_party_house`, `pro_reckless_driving`, `pro_online_rant`, `pro_gambling_debt`, `pro_banned_substance`, `pro_night_before`, `pro_late_meeting`, `pro_casual_bet`, `pro_betting_scandal`, `pro_solicitation`, `pro_business_fraud`, `pro_phantom_injury`, `pro_bad_mentor`, `pro_insurance_fraud`.
**Relationship strike flags** (the cheating storyline PRO_155-163; never read by team discipline): `pro_cheated`, `affair_public`.
College flags set severity through locked choices.

**Totals:** 840 scenes. **703 can be written now**: 619 need nothing new, and 84 are money scenes written with flags and stress costs. **137 are blocked** until R1, R10, R8, R9 lands. Kinds: 765 once, 31 repeat, 29 variant, 3 per_club, 12 epilogue.

| Waits on | Scenes |
|---|---|
| R1 | 120: 143, 144, 150, 176, 177, 181, 182, 186, 187, 189, 190, 194, 195, 198, 199, 217, 308, 465, 466, 467, 468, 469, 470, 471, 472, 473, 474, 475, 476, 477, 478, 479, 480, 481, 482, 483, 484, 485, 486, 487, 488, 489, 490, 491, 492, 493, 494, 495, 496, 497, 498, 499, 500, 501, 502, 503, 504, 505, 506, 507, 508, 509, 510, 511, 512, 513, 514, 515, 516, 517, 518, 519, 520, 521, 522, 523, 524, 525, 526, 527, 528, 529, 530, 531, 532, 533, 534, 535, 536, 537, 538, 539, 812, 813, 814, 815, 816, 817, 818, 819, 820, 821, 822, 823, 824, 825, 826, 827, 828, 829, 830, 831, 832, 833, 834, 835, 836, 837, 838, 839 |
| R10 | 12: E01, E02, E03, E04, E05, E06, E07, E08, E09, E10, E11, E12 |
| R3 | 91: 003, 007, 026, 031, 040, 056, 057, 059, 060, 061, 062, 063, 064, 065, 066, 067, 068, 069, 070, 071, 072, 073, 123, 135, 163, 233, 234, 235, 236, 261, 262, 266, 287, 303, 310, 325, 326, 338, 341, 342, 350, 358, 359, 360, 365, 371, 373, 374, 376, 384, 394, 400, 401, 421, 429, 432, 437, 445, 455, 463, 481, 482, 483, 498, 505, 526, 558, 559, 560, 569, 594, 607, 632, 633, 647, 648, 655, 659, 660, 665, 674, 711, 712, 713, 714, 717, 718, 771, 782, 784, 799 |
| R8 | 3: 151, 219, 220 |
| R9 | 2: 262, 268 |

| Era | Scenes | Written | Waits on R1 | R3 (money values) | R8 | R9 | R10 | Blocked (cannot be written yet) |
|---|---|---|---|---|---|---|---|---|
| Era 1: Rookie (22-25) | 150 | 150 | 0 | 18 | 0 | 0 | 0 | 0 |
| Era 2: Settled In (26-29) | 150 | 150 | 0 | 26 | 0 | 0 | 0 | 0 |
| Era 3: Veteran (30-33) | 150 | 148 | 0 | 17 | 2 | 0 | 0 | 2 |
| Era 4: Aging Veteran (34-37) | 150 | 20 | 0 | 14 | 0 | 2 | 0 | 2 |
| Era 5: Grizzled Veteran (38-41) | 80 | 0 | 80 | 5 | 0 | 0 | 0 | 0 |
| Era 6: Hall of Fame Era (42+) | 40 | 0 | 40 | 1 | 0 | 0 | 0 | 40 |
| Across eras (state-driven) | 108 | 22 | 0 | 10 | 1 | 0 | 0 | 1 |
| Epilogue (after retirement) | 12 | 0 | 0 | 0 | 0 | 0 | 12 | 12 |

Era 5 counts the age-38 scenes as playable now (the cap retires a player after the age-38 season); its ages 39-41 wait on R1. Eras 5 and 6 and the epilogue are proposals until the user confirms them.

**Chains:**
- Rookie: PRO_001 → PRO_002 → PRO_003 → PRO_004 → PRO_005 → PRO_006 → PRO_007 → PRO_008 → PRO_009 → PRO_010 → PRO_011 → PRO_012 → PRO_013 → PRO_014 → PRO_015
- Slump: PRO_016 → PRO_017 → PRO_024 → PRO_025 → PRO_027 → PRO_035 → PRO_178 → PRO_179 → PRO_180 → PRO_181 → PRO_182
- Benched: PRO_018 → PRO_019
- Streak: PRO_020 → PRO_021 → PRO_033 → PRO_183 → PRO_184 → PRO_185 → PRO_186 → PRO_187
- Awards: PRO_022 → PRO_023
- Injury: PRO_028 → PRO_191 → PRO_192 → PRO_193 → PRO_194 → PRO_195
- Competition: PRO_029 → PRO_030 → PRO_032 → PRO_188 → PRO_189 → PRO_190
- Business: PRO_031 → PRO_052 → PRO_053 → PRO_054 → PRO_103 → PRO_104 → PRO_105 → PRO_106 → PRO_233 → PRO_234 → PRO_235 → PRO_236 → PRO_237
- Media: PRO_034 → PRO_107 → PRO_108 → PRO_109 → PRO_110
- Contract: PRO_036 → PRO_037 → PRO_038 → PRO_039 → PRO_040 → PRO_041 → PRO_055 → PRO_176 → PRO_177
- New club: PRO_042 → PRO_043 → PRO_044 → PRO_045 → PRO_046 → PRO_047 → PRO_051 → PRO_196 → PRO_197 → PRO_198 → PRO_199
- Agent: PRO_048 → PRO_049 → PRO_050
- Money: PRO_056 → PRO_057 → PRO_058 → PRO_059 → PRO_060 → PRO_061 → PRO_062 → PRO_063 → PRO_064 → PRO_065 → PRO_066 → PRO_067 → PRO_068 → PRO_069 → PRO_070 → PRO_071 → PRO_072 → PRO_073
- Partner: PRO_074 → PRO_075 → PRO_079 → PRO_095 → PRO_096 → PRO_151 → PRO_219 → PRO_220 → PRO_221
- Family: PRO_076 → PRO_077 → PRO_078 → PRO_080 → PRO_081 → PRO_082 → PRO_146 → PRO_225
- Friends: PRO_083 → PRO_084 → PRO_097 → PRO_098 → PRO_226 → PRO_227 → PRO_228
- Rival: PRO_085 → PRO_086 → PRO_087
- Mentor: PRO_088 → PRO_089
- Teammates: PRO_090 → PRO_091 → PRO_092 → PRO_093
- Locker room: PRO_099 → PRO_100 → PRO_101 → PRO_102 → PRO_111 → PRO_112 → PRO_113 → PRO_114 → PRO_115
- Wrong path: PRO_116 → PRO_117 → PRO_118 → PRO_119 → PRO_120 → PRO_121 → PRO_122 → PRO_123 → PRO_129 → PRO_130
- Wrong path step: PRO_124 → PRO_125 → PRO_126 → PRO_127 → PRO_128
- Veteran: PRO_131 → PRO_132 → PRO_133 → PRO_134 → PRO_135 → PRO_136 → PRO_143 → PRO_144 → PRO_145 → PRO_147 → PRO_150
- Retirement: PRO_137 → PRO_138
- Forced out: PRO_139 → PRO_148
- Comeback: PRO_140 → PRO_238
- After: PRO_141 → PRO_142 → PRO_149 → PRO_229 → PRO_230 → PRO_231 → PRO_232
- Single: PRO_152 → PRO_153 → PRO_154
- Temptation: PRO_155 → PRO_156 → PRO_157 → PRO_158 → PRO_159 → PRO_160 → PRO_161 → PRO_162 → PRO_163
- Banned substance: PRO_164 → PRO_165
- Late: PRO_167 → PRO_168 → PRO_169 → PRO_289 → PRO_290 → PRO_291 → PRO_292 → PRO_293 → PRO_294 → PRO_295 → PRO_296 → PRO_297 → PRO_298 → PRO_299 → PRO_300 → PRO_301 → PRO_302 → PRO_303 → PRO_304 → PRO_305 → PRO_306 → PRO_307 → PRO_308
- Betting: PRO_170 → PRO_171 → PRO_172
- Solicitation: PRO_173 → PRO_174 → PRO_175
- Repeat: PRO_200 → PRO_201 → PRO_202 → PRO_203 → PRO_204 → PRO_205 → PRO_206 → PRO_207 → PRO_208 → PRO_209 → PRO_210 → PRO_211 → PRO_212 → PRO_213
- Kids: PRO_214 → PRO_215 → PRO_216 → PRO_217 → PRO_218
- Parent: PRO_222 → PRO_223 → PRO_224
- Legacy: PRO_239 → PRO_240 → PRO_241 → PRO_242 → PRO_243
- Wind-down: PRO_244 → PRO_245 → PRO_246 → PRO_247 → PRO_248 → PRO_249 → PRO_250 → PRO_251 → PRO_252 → PRO_253 → PRO_254 → PRO_255 → PRO_256 → PRO_257 → PRO_258
- Veteran wrong path: PRO_259 → PRO_260 → PRO_261 → PRO_262 → PRO_263 → PRO_264 → PRO_265 → PRO_266 → PRO_267 → PRO_268
- Offseason: PRO_269 → PRO_270 → PRO_271 → PRO_272 → PRO_273 → PRO_274 → PRO_275 → PRO_276 → PRO_277 → PRO_278 → PRO_279 → PRO_280 → PRO_281 → PRO_282 → PRO_283 → PRO_284 → PRO_285 → PRO_286 → PRO_287 → PRO_288
- Mid-career: PRO_309 → PRO_310 → PRO_311 → PRO_312 → PRO_313 → PRO_314 → PRO_315 → PRO_316 → PRO_317 → PRO_318 → PRO_319 → PRO_320
- Seed list: PRO_321 → PRO_322 → PRO_323 → PRO_324 → PRO_325 → PRO_326 → PRO_327 → PRO_328 → PRO_329 → PRO_330 → PRO_331 → PRO_332 → PRO_333 → PRO_334 → PRO_335 → PRO_336 → PRO_337 → PRO_338 → PRO_339 → PRO_340 → PRO_341 → PRO_342 → PRO_343 → PRO_344 → PRO_345 → PRO_346 → PRO_347 → PRO_348 → PRO_349 → PRO_350 → PRO_351 → PRO_352 → PRO_353 → PRO_354 → PRO_355 → PRO_356 → PRO_357 → PRO_358 → PRO_359 → PRO_360 → PRO_361 → PRO_362 → PRO_363 → PRO_364 → PRO_365 → PRO_366 → PRO_367 → PRO_368 → PRO_369 → PRO_370 → PRO_371 → PRO_372 → PRO_373 → PRO_374 → PRO_375 → PRO_376 → PRO_377 → PRO_378 → PRO_379 → PRO_380 → PRO_381 → PRO_382 → PRO_383 → PRO_384 → PRO_385 → PRO_386 → PRO_387 → PRO_388 → PRO_389 → PRO_390 → PRO_391 → PRO_392 → PRO_393 → PRO_394 → PRO_395 → PRO_396 → PRO_397 → PRO_398 → PRO_399 → PRO_400 → PRO_401 → PRO_402 → PRO_403 → PRO_404 → PRO_405 → PRO_406 → PRO_407 → PRO_408 → PRO_409 → PRO_410 → PRO_411 → PRO_412 → PRO_413 → PRO_414 → PRO_415 → PRO_416 → PRO_417 → PRO_418 → PRO_419 → PRO_420 → PRO_421 → PRO_422 → PRO_423 → PRO_424 → PRO_425 → PRO_426 → PRO_427 → PRO_428 → PRO_429 → PRO_430 → PRO_431 → PRO_432 → PRO_433 → PRO_434 → PRO_435 → PRO_436 → PRO_437 → PRO_438 → PRO_439 → PRO_440 → PRO_441 → PRO_442 → PRO_443 → PRO_444 → PRO_445 → PRO_446 → PRO_447 → PRO_448 → PRO_449 → PRO_450 → PRO_451 → PRO_452 → PRO_453 → PRO_454 → PRO_455 → PRO_456 → PRO_457 → PRO_458 → PRO_459 → PRO_460 → PRO_461 → PRO_462 → PRO_463 → PRO_464 → PRO_465 → PRO_466 → PRO_467 → PRO_468 → PRO_469 → PRO_470 → PRO_471 → PRO_472 → PRO_473 → PRO_474 → PRO_475 → PRO_476 → PRO_477 → PRO_478 → PRO_479 → PRO_480 → PRO_481 → PRO_482 → PRO_483 → PRO_484 → PRO_485 → PRO_486 → PRO_487 → PRO_488 → PRO_489 → PRO_490 → PRO_491 → PRO_492 → PRO_493 → PRO_494 → PRO_495 → PRO_496 → PRO_497 → PRO_498 → PRO_499 → PRO_500 → PRO_501 → PRO_502 → PRO_503 → PRO_504 → PRO_505 → PRO_506 → PRO_507 → PRO_508 → PRO_509 → PRO_510 → PRO_511 → PRO_512 → PRO_513 → PRO_514 → PRO_515 → PRO_516 → PRO_517 → PRO_518 → PRO_519 → PRO_520 → PRO_521 → PRO_522 → PRO_523 → PRO_524 → PRO_525 → PRO_526 → PRO_527 → PRO_528 → PRO_529 → PRO_530 → PRO_531 → PRO_532 → PRO_533 → PRO_534 → PRO_535 → PRO_536 → PRO_537 → PRO_538 → PRO_539
- New: PRO_551 → PRO_552 → PRO_553 → PRO_554 → PRO_555 → PRO_556 → PRO_557 → PRO_558 → PRO_559 → PRO_560 → PRO_561 → PRO_562 → PRO_563 → PRO_564 → PRO_565 → PRO_566 → PRO_567 → PRO_568 → PRO_569 → PRO_570 → PRO_571 → PRO_572 → PRO_573 → PRO_574 → PRO_575 → PRO_576 → PRO_577 → PRO_578 → PRO_579 → PRO_580 → PRO_581 → PRO_582 → PRO_583 → PRO_584 → PRO_585 → PRO_586 → PRO_587 → PRO_588 → PRO_589 → PRO_590 → PRO_591 → PRO_592 → PRO_593 → PRO_594 → PRO_595 → PRO_596 → PRO_597 → PRO_598 → PRO_599 → PRO_600 → PRO_601 → PRO_602 → PRO_603 → PRO_604 → PRO_605 → PRO_606 → PRO_607 → PRO_608 → PRO_609 → PRO_610 → PRO_611 → PRO_612 → PRO_613 → PRO_614 → PRO_615 → PRO_616 → PRO_617 → PRO_618 → PRO_619 → PRO_620 → PRO_621 → PRO_622 → PRO_623 → PRO_624 → PRO_625 → PRO_626 → PRO_627 → PRO_628 → PRO_629 → PRO_630 → PRO_631 → PRO_632 → PRO_633 → PRO_634 → PRO_635 → PRO_636 → PRO_637 → PRO_638 → PRO_639 → PRO_640 → PRO_641 → PRO_642 → PRO_643 → PRO_644 → PRO_645 → PRO_646 → PRO_647 → PRO_648 → PRO_649 → PRO_650 → PRO_651 → PRO_652 → PRO_653 → PRO_654 → PRO_655 → PRO_656 → PRO_657 → PRO_658 → PRO_659 → PRO_660 → PRO_661 → PRO_662 → PRO_663 → PRO_664 → PRO_665 → PRO_666 → PRO_667 → PRO_668 → PRO_669 → PRO_670 → PRO_671 → PRO_672 → PRO_673 → PRO_674 → PRO_675 → PRO_676 → PRO_677 → PRO_678 → PRO_679 → PRO_680 → PRO_681 → PRO_682 → PRO_683 → PRO_684 → PRO_685 → PRO_686 → PRO_687 → PRO_688 → PRO_689 → PRO_690 → PRO_691 → PRO_692 → PRO_693 → PRO_694 → PRO_695 → PRO_696 → PRO_697 → PRO_698 → PRO_699 → PRO_700 → PRO_701 → PRO_702 → PRO_703 → PRO_704 → PRO_705 → PRO_706 → PRO_707 → PRO_708 → PRO_709 → PRO_710 → PRO_711 → PRO_712 → PRO_713 → PRO_714 → PRO_715 → PRO_716 → PRO_717 → PRO_718 → PRO_719 → PRO_720 → PRO_721 → PRO_722 → PRO_723 → PRO_724 → PRO_725 → PRO_726 → PRO_727 → PRO_728 → PRO_729 → PRO_730 → PRO_731 → PRO_732 → PRO_733 → PRO_734 → PRO_735 → PRO_736 → PRO_737 → PRO_738 → PRO_739 → PRO_740 → PRO_741 → PRO_742 → PRO_743 → PRO_744 → PRO_745 → PRO_746 → PRO_747 → PRO_748 → PRO_749 → PRO_750 → PRO_751 → PRO_752 → PRO_753 → PRO_754 → PRO_755 → PRO_756 → PRO_757 → PRO_758 → PRO_759 → PRO_760 → PRO_761 → PRO_762 → PRO_763 → PRO_764 → PRO_765 → PRO_766 → PRO_767 → PRO_768 → PRO_769 → PRO_770 → PRO_771 → PRO_772 → PRO_773 → PRO_774 → PRO_775 → PRO_776 → PRO_777 → PRO_778 → PRO_779 → PRO_780 → PRO_781 → PRO_782 → PRO_783 → PRO_784 → PRO_785 → PRO_786 → PRO_787 → PRO_788 → PRO_789 → PRO_790 → PRO_791 → PRO_792 → PRO_793 → PRO_794 → PRO_795 → PRO_796 → PRO_797 → PRO_798 → PRO_799 → PRO_800 → PRO_801 → PRO_802 → PRO_803 → PRO_804 → PRO_805 → PRO_806 → PRO_807 → PRO_808 → PRO_809 → PRO_810 → PRO_811 → PRO_812 → PRO_813 → PRO_814 → PRO_815 → PRO_816 → PRO_817 → PRO_818 → PRO_819 → PRO_820 → PRO_821 → PRO_822 → PRO_823 → PRO_824 → PRO_825 → PRO_826 → PRO_827 → PRO_828 → PRO_829 → PRO_830 → PRO_831 → PRO_832 → PRO_833 → PRO_834 → PRO_835 → PRO_836 → PRO_837 → PRO_838 → PRO_839
- Epilogue: PRO_E01 → PRO_E02 → PRO_E03 → PRO_E04 → PRO_E05 → PRO_E06 → PRO_E07 → PRO_E08 → PRO_E09 → PRO_E10 → PRO_E11 → PRO_E12

## Era 1: Rookie (22-25) (150)

| ID | Title | Window | Kind | Opens on | Sets | Callbacks (locked choices) | Waits on |
|---|---|---|---|---|---|---|---|
| PRO_001 | Rookie Camp | age 21-25, club season 1, weeks 1-2, story | once |  |  | rebuilt_reputation, trained_with_alum |  |
| PRO_002 | The Kicker You're Replacing | age 21-25, club season 1, weeks 1-4 | once |  | learned_from_veteran, froze_out_veteran |  |  |
| PRO_003 | Your First Real Payday | age 21-25, club season 1 | once |  | saved_rookie_check, spent_rookie_check, paid_family_debt | saved_first_paycheck, helped_family_financially | R3 money values |
| PRO_004 | Rookie Duties | age 21-25, club season 1 | once |  |  | ended_tradition, kept_tradition_alive |  |
| PRO_005 | The Long Snapper | age 21-25, club seasons 1-2 | once |  | trusted_snapper |  |  |
| PRO_006 | Curfew on the Road | age 21-25, club season 1 | once |  | stayed_out_pro |  |  |
| PRO_007 | Where You Live | age 21-25, club season 1 | once |  | lived_modestly, lived_large |  | R3 money values |
| PRO_008 | Homesick in {town} | age 21-25, club season 1 | once |  |  | promised_to_call_home |  |
| PRO_009 | The Practice Squad Friend | age 21-25, club seasons 1-2 | once |  |  |  |  |
| PRO_010 | Meeting the Owner | age 21-25, club season 1 | once |  |  |  |  |
| PRO_011 | The Quote | age 21-25, club seasons 1-2 | once |  |  | handled_old_post, online_incident |  |
| PRO_012 | Your First Autograph Line | age 21-25, club seasons 1-2 | once |  |  |  |  |
| PRO_013 | Rookie Year Ends | age 21-25, club season 1, offseason | once |  |  |  |  |
| PRO_014 | The Second-Year Wall | age 21-25, club season 2, weeks 1-4 | once |  |  |  |  |
| PRO_015 | Your Story, Secondhand | age 21-25, club seasons 1-2 | once | owned_mistake / rebuilt_reputation / took_responsibility_scout |  |  |  |
| PRO_029 | The Backup Wants Your Job | age 21-25 | once |  |  |  |  |
| PRO_030 | The New Holder Midseason | age 21-25 | once |  |  |  |  |
| PRO_034 | The Kick Everyone Saw | age 21-25 | once |  |  |  |  |
| PRO_036 | Contract Year: Prove It | age 21-25 | variant | contract_year |  |  |  |
| PRO_050 | The Good Agent | age 21-25 | once |  | good_agent |  |  |
| PRO_057 | The Honest Advisor | age 21-25 | once |  | honest_advisor |  | R3 money values |
| PRO_058 | The Advisor With the Yacht | age 21-25 | once |  | trusted_flashy_advisor | good_agent, honest_advisor |  |
| PRO_066 | The Tax Letter, Pro | age 21-25 | once |  |  | saved_first_paycheck | R3 money values |
| PRO_068 | The Cousin Nobody Remembers | age 21-25 | once |  |  |  | R3 money values |
| PRO_071 | The Watch, the Car, the Chain | age 21-25 | once |  |  |  | R3 money values |
| PRO_085 | {tyler} in the Same Division | age 21-25 | once |  | tyler_division_rival | tyler_mutual_respect, congratulated_tyler, trash_talked_tyler |  |
| PRO_100 | The Quarterback's Ego | age 21-25 | once |  |  |  |  |
| PRO_106 | The Owner's Gala | age 21-25 | once |  |  |  |  |
| PRO_112 | The Specialists' Dinner | age 21-25 | once |  |  |  |  |
| PRO_115 | The Trick Play | age 21-25 | once |  |  |  |  |
| PRO_178 | The Rookie Slump | age 21-25 | variant | slump_now 1+ |  | saw_sports_psych, leaned_on_support |  |
| PRO_183 | The Rookie on a Run | age 21-25 | variant | fg_streak 8+ |  |  |  |
| PRO_188 | The Veteran They Signed to Push You | age 21-25, weeks 1-3 | variant |  |  |  |  |
| PRO_191 | The Rookie Injury | age 21-25 | variant | injured_now 1+ |  | committed_to_recovery, hid_injury |  |
| PRO_269 | Summer at Home | age 21-25, offseason | once |  |  |  |  |
| PRO_321 | The Veteran's Advice | age 21-25 | once |  |  |  |  |
| PRO_322 | The First Media Interview | age 21-25 | once |  |  |  |  |
| PRO_323 | The Missed Opportunity | age 21-25 | once |  |  |  |  |
| PRO_324 | The Agent Calls | age 21-25 | once |  |  |  |  |
| PRO_325 | The First Endorsement | age 21-25 | once |  |  |  | R3 money values |
| PRO_326 | The Old Friend's Request | age 21-25 | once |  |  |  | R3 money values |
| PRO_327 | The Long-Distance Relationship | age 21-25 | once | made_long_distance_work / committed_to_relationship; not engaged / married |  |  |  |
| PRO_328 | The Coach's Criticism | age 21-25 | once |  |  |  |  |
| PRO_329 | The Rookie Mistake | age 21-25 | once |  |  |  |  |
| PRO_330 | The First Charity Event | age 21-25 | once |  |  |  |  |
| PRO_331 | The Social Media Post | age 21-25 | once |  |  | handled_old_post |  |
| PRO_332 | The Teammate's Party | age 21-25 | once |  |  |  |  |
| PRO_333 | The New City | age 21-25 | once |  |  |  |  |
| PRO_334 | The Family Visit | age 21-25 | once |  |  |  |  |
| PRO_335 | The Unexpected Attention | age 21-25 | once |  |  |  |  |
| PRO_336 | The Local Radio Appearance | age 21-25 | once |  |  |  |  |
| PRO_337 | The Practice Routine | age 21-25 | once |  |  |  |  |
| PRO_338 | The Equipment Upgrade | age 21-25 | once |  |  |  | R3 money values |
| PRO_339 | The First Contract Question | age 21-25 | once |  |  |  |  |
| PRO_340 | The Teammate's Struggle | age 21-25 | once |  |  |  |  |
| PRO_341 | The Family Expectations | age 21-25 | once |  |  |  | R3 money values |
| PRO_342 | The Unexpected Bill | age 21-25 | once |  |  |  | R3 money values |
| PRO_343 | The Former Coach Calls | age 21-25 | once |  |  |  |  |
| PRO_344 | The Community Invitation | age 21-25 | once |  |  |  |  |
| PRO_345 | The Dating Question | age 21-25 | once | not made_long_distance_work / committed_to_relationship / new_partner / engaged / married / dating_classmate |  |  |  |
| PRO_346 | The Teammate's Celebration | age 21-25 | once |  |  |  |  |
| PRO_347 | The Position Meeting | age 21-25 | once |  |  |  |  |
| PRO_348 | The New Playbook | age 21-25 | once |  |  |  |  |
| PRO_349 | The Rookie Comparison | age 21-25 | once |  |  |  |  |
| PRO_350 | The Charity Donation | age 21-25 | once |  |  |  | R3 money values |
| PRO_351 | The Teammate's Advice | age 21-25 | once |  |  |  |  |
| PRO_352 | The Agent's Warning | age 21-25 | once |  |  |  |  |
| PRO_353 | The Apartment Neighbor | age 21-25 | once |  |  |  |  |
| PRO_354 | The Unexpected Criticism | age 21-25 | once |  |  |  |  |
| PRO_355 | The Second Contract Conversation | age 21-25 | once |  |  |  |  |
| PRO_356 | The Veteran's Rules | age 21-25 | once |  |  |  |  |
| PRO_551 | The Playbook Test | age 21-25 | once |  |  |  |  |
| PRO_552 | Learning the Snap Count | age 21-25 | once |  |  |  |  |
| PRO_553 | The Wind Tunnel | age 21-25 | once |  |  |  |  |
| PRO_554 | The Scout Team | age 21-25 | once |  |  |  |  |
| PRO_555 | The Weight Room Pecking Order | age 21-25 | once |  |  |  |  |
| PRO_556 | The Equipment Manager | age 21-25 | once |  |  |  |  |
| PRO_557 | The First Fine | age 21-25 | once |  |  |  |  |
| PRO_558 | The Meal Money | age 21-25 | once |  |  |  | R3 money values |
| PRO_559 | Rookie Year Taxes | age 21-25 | once |  |  |  | R3 money values |
| PRO_560 | Free Cleats | age 21-25 | once |  |  |  | R3 money values |
| PRO_561 | The Kicking Ball Room | age 21-25 | once |  |  |  |  |
| PRO_562 | The Trainer's Table | age 21-25 | once |  |  |  |  |
| PRO_563 | Your First Locker | age 21-25 | once |  |  |  |  |
| PRO_564 | The Group Text | age 21-25 | once |  |  |  |  |
| PRO_565 | The Ride to Practice | age 21-25 | once |  |  |  |  |
| PRO_566 | The Rookie Show | age 21-25 | once |  |  |  |  |
| PRO_567 | The Fan Event | age 21-25 | once |  |  |  |  |
| PRO_568 | The Hometown Paper | age 21-25 | once |  |  |  |  |
| PRO_569 | The Card Signing | age 21-25 | once |  |  |  | R3 money values |
| PRO_570 | The Holder Who Won't Talk | age 21-25 | once |  |  |  |  |
| PRO_571 | The First Night Game | age 21-25 | once |  |  |  |  |
| PRO_572 | Sleeping on the Plane | age 21-25 | once |  |  |  |  |
| PRO_573 | The Hotel Roommate | age 21-25 | once |  |  |  |  |
| PRO_574 | The Waiver Wire | age 21-25 | once |  |  |  |  |
| PRO_575 | The Rookie Contract | age 21-25 | once |  |  |  |  |
| PRO_576 | The Kicker Down the Hall | age 21-25 | once |  |  |  |  |
| PRO_577 | The Film You Hate | age 21-25 | once |  |  |  |  |
| PRO_578 | Your Parents in the Stands | age 21-25 | once |  |  |  |  |
| PRO_579 | The Sibling Who Wants to Visit | age 21-25 | once |  |  |  |  |
| PRO_580 | The College Teammates' Chat | age 21-25 | once |  |  |  |  |
| PRO_581 | The Old Girlfriend | age 21-25 | once | not made_long_distance_work / committed_to_relationship / new_partner / engaged / married / dating_classmate |  |  |  |
| PRO_582 | Your First Bad Practice Week | age 21-25 | once |  |  |  |  |
| PRO_583 | The Veteran's Car | age 21-25 | once |  |  |  |  |
| PRO_584 | Learning to Cook | age 21-25 | once |  |  |  |  |
| PRO_585 | The Team Nutritionist | age 21-25 | once |  |  |  |  |
| PRO_586 | The Sleep Study | age 21-25 | once |  |  |  |  |
| PRO_587 | The Team Psychologist | age 21-25 | once |  |  | saw_sports_psych |  |
| PRO_588 | The Rookie Who Doesn't Make It | age 21-25 | once |  |  |  |  |
| PRO_589 | The Practice-Field Fan | age 21-25 | once |  |  |  |  |
| PRO_590 | Kicks for the Hospital | age 21-25 | once |  |  |  |  |
| PRO_591 | The Night Before Your Debut | age 21-25 | once |  |  |  |  |
| PRO_592 | The Debut Week Interview | age 21-25 | once |  |  |  |  |
| PRO_593 | The Team Photo | age 21-25 | once |  |  |  |  |
| PRO_594 | The Rookie Payday Dinner | age 21-25 | once |  |  |  | R3 money values |
| PRO_595 | The Trainer's Warning | age 21-25 | once |  |  |  |  |
| PRO_596 | The Rookie Who Talks Too Much | age 21-25 | once |  |  |  |  |
| PRO_597 | The Specialist Meeting Room | age 21-25 | once |  |  |  |  |
| PRO_598 | The Wrong Bus | age 21-25 | once |  |  |  |  |
| PRO_599 | Your First Billboard | age 21-25 | once |  |  |  |  |
| PRO_600 | The Veteran's Retirement Party | age 21-25 | once |  |  |  |  |
| PRO_601 | The Mentor Who Leaves | age 21-25 | once |  |  |  |  |
| PRO_602 | The Agent's Other Rookies | age 21-25 | once |  |  |  |  |
| PRO_603 | The Practice Squad Promotion | age 21-25 | once |  |  |  |  |
| PRO_604 | The Bad Haircut | age 21-25 | once |  |  |  |  |
| PRO_605 | The Family Group Chat | age 21-25 | once |  |  |  |  |
| PRO_606 | The Fantasy Football Message | age 21-25 | once |  |  |  |  |
| PRO_607 | Your First Credit Card Bill | age 21-25 | once |  |  |  | R3 money values |
| PRO_608 | The Gym Membership | age 21-25 | once |  |  |  |  |
| PRO_609 | The Kicking Coach From College | age 21-25 | once |  |  |  |  |
| PRO_610 | The Cold-Weather City | age 21-25 | once |  |  |  |  |
| PRO_611 | The Hot-Weather Road Game | age 21-25 | once |  |  |  |  |
| PRO_612 | The Long Flight | age 21-25 | once |  |  |  |  |
| PRO_613 | The Jersey Number | age 21-25 | once |  |  |  |  |
| PRO_614 | The Rookie Quiz | age 21-25 | once |  |  |  |  |
| PRO_615 | The Holiday Away From Home | age 21-25 | once |  |  |  |  |
| PRO_616 | The Team Thanksgiving | age 21-25 | once |  |  |  |  |
| PRO_617 | The Teammate's Baby | age 21-25 | once |  |  |  |  |
| PRO_618 | The Rookie Year Review | age 21-25, offseason | once |  |  |  |  |
| PRO_619 | The Offseason Without Structure | age 21-25, offseason | once |  |  |  |  |
| PRO_620 | The Old College Rival | age 21-25 | once |  |  |  |  |
| PRO_621 | The Rookie Hazing Report | age 21-25 | once |  |  |  |  |
| PRO_622 | The Fan Who Sends Gifts | age 21-25 | once |  |  |  |  |
| PRO_623 | Your First Endorsement Shoot | age 21-25 | once | tier verified |  |  |  |
| PRO_624 | The Rookie Who Wants Your Spot | age 21-25 | once |  |  |  |  |
| PRO_625 | The New Club as a Rookie | age 21-25, club season 1, weeks 1-3 | once | signed_new_club + released |  |  |  |
| PRO_626 | The First Time You Hear Boos | age 21-25 | once |  |  |  |  |
| PRO_627 | The Phone Call Home | age 21-25 | once |  |  |  |  |
| PRO_628 | The Rookie Paycheck Math | age 21-25 | once |  |  |  |  |
| PRO_629 | The Rookie Who Calls Home Crying | age 21-25 | once |  |  |  |  |

- **PRO_001 Rookie Camp**: Camp opens with four kickers on the roster and one job. The veteran special teams coordinator calls you by the wrong name twice.
- **PRO_002 The Kicker You're Replacing**: The kicker whose job you're taking has been here eleven years. He can make your first month easy or impossible.
- **PRO_003 Your First Real Payday**: Your first real paycheck lands, and it has more zeros than {parent} made in a year.
- **PRO_004 Rookie Duties**: The veterans hand the rookies a list: breakfast for the unit every Friday, the luggage, the karaoke on the team plane. Some of it is fun. One item isn't.
- **PRO_005 The Long Snapper**: The long snapper has been in the league fourteen years and has opinions about everything, including your warmup.
- **PRO_006 Curfew on the Road**: First road trip. Curfew is eleven, and the veterans say curfew is for rookies who want to stay rookies. *(Pressure scene: clean no. The wrong choice sets pro strike stayed_out_pro.)*
- **PRO_007 Where You Live**: Half the roster lives in the same glass tower downtown. The rent is a quarter of your salary.
- **PRO_008 Homesick in {town}**: Nobody in {town} knows your name yet, and the apartment is very quiet on Tuesday nights.
- **PRO_009 The Practice Squad Friend**: The receiver you've been eating lunch with since camp gets cut on a Tuesday morning. He's still in the parking lot at noon.
- **PRO_010 Meeting the Owner**: The owner throws a party for the rookies at his house and spends twenty minutes telling you what kickers are worth.
- **PRO_011 The Quote**: You said something careless to a beat reporter about the veteran you replaced, and it's the headline.
- **PRO_012 Your First Autograph Line**: A kid in a jersey with your number on it is first in line. You didn't know they made your number.
- **PRO_013 Rookie Year Ends**: The season's over. The locker room empties in an afternoon, and you realize you have no idea what pros do in the offseason.
- **PRO_014 The Second-Year Wall**: Year two. The novelty is gone, the scouting reports on you are thicker, and your legs feel every one of last season's kicks.
- **PRO_015 Your Story, Secondhand**: A former teammate from college calls from his rookie symposium: they told a story about someone who sounds a lot like you. *(College callback scene: opens only for players with a college comeback; pairs with pro_rookie_symposium.)*
- **PRO_029 The Backup Wants Your Job**: {backup} is on the practice squad and has been kicking very well where the coaches can see.
- **PRO_030 The New Holder Midseason**: {holder} is hurt, and the replacement holder is a backup quarterback who has never held for a kick.
- **PRO_034 The Kick Everyone Saw**: A clip of you in a practice-field trick shot goes around the league. *(Practice clip only; no game result.)*
- **PRO_036 Contract Year: Prove It**: It's the last year of your rookie deal, and the front office wants to see one more season before they talk.
- **PRO_050 The Good Agent**: An agent with six clients asks for an hour to show you a plan with no flash in it at all.
- **PRO_057 The Honest Advisor**: A financial advisor recommended by your snapper walks you through a plan so boring it's almost funny.
- **PRO_058 The Advisor With the Yacht**: A financial advisor who manages three teammates invites you onto his boat and talks about 'real returns'.
- **PRO_066 The Tax Letter, Pro**: You owe taxes in every state you played a road game in, and your old accountant didn't file most of them.
- **PRO_068 The Cousin Nobody Remembers**: Someone from your hometown with your last name and a business idea is waiting by your car.
- **PRO_071 The Watch, the Car, the Chain**: The locker room has a dress code nobody wrote down, and it costs about your rookie salary.
- **PRO_085 {tyler} in the Same Division**: {tyler} signs with a division rival, and the media has already made the graphic.
- **PRO_100 The Quarterback's Ego**: The franchise quarterback blames the special teams in a press conference.
- **PRO_106 The Owner's Gala**: Black tie, the owner's charity, and a donor who wants a photo and a favor.
- **PRO_112 The Specialists' Dinner**: The kicker, the punter and the snapper have a weekly dinner, and a new punter wants in.
- **PRO_115 The Trick Play**: The new coordinator wants a fake field goal with you throwing the pass, and you haven't thrown a ball since high school.
- **PRO_178 The Rookie Slump**: Your first real slump, and every veteran in the room has a theory about your plant foot.
- **PRO_183 The Rookie on a Run**: A month without a miss, and the rookie card companies are calling your agent.
- **PRO_188 The Veteran They Signed to Push You**: The club signs a thirty-four-year-old kicker 'for depth'. Everybody knows what that means for a rookie.
- **PRO_191 The Rookie Injury**: Your first pro injury, and the trainers are talking about you like a part that might not fit back in.
- **PRO_269 Summer at Home**: Your first offseason back home, and everyone at the grocery store wants to talk about one kick.
- **PRO_321 The Veteran's Advice**: An established teammate pulls you aside with a few rules for surviving the league.
- **PRO_322 The First Media Interview**: Local reporters catch you at your locker before you've learned what not to say.
- **PRO_323 The Missed Opportunity**: A bad practice in front of the whole staff, and someone in the building is already asking about your roster spot.
- **PRO_324 The Agent Calls**: Your agent calls to talk about your contract, your future and a few things you'd rather not hear.
- **PRO_325 The First Endorsement**: A local business offers you your first sponsorship: a billboard, a few appearances, a small check.
- **PRO_326 The Old Friend's Request**: Someone from home asks you for money, and you can tell it took a lot to ask.
- **PRO_327 The Long-Distance Relationship**: {love_interest} is three states away, and your schedule doesn't have room for flights.
- **PRO_328 The Coach's Criticism**: {coach} tells you, in front of the specialists, that your preparation isn't professional yet.
- **PRO_329 The Rookie Mistake**: You make an embarrassing mistake at a team event, and the veterans won't let you forget it.
- **PRO_330 The First Charity Event**: The club sends you to represent it at a community event, and nobody tells you what to say.
- **PRO_331 The Social Media Post**: An old post resurfaces the week your name starts showing up in the papers.
- **PRO_332 The Teammate's Party**: A teammate's party the night before an early workday, and the whole rookie class is going.
- **PRO_333 The New City**: You can explore {town} or stay in your apartment with the blinds closed.
- **PRO_334 The Family Visit**: Your family wants to visit for a weekend, and your schedule doesn't have a weekend in it.
- **PRO_335 The Unexpected Attention**: Someone recognizes you at the grocery store and won't stop talking.
- **PRO_336 The Local Radio Appearance**: A sports radio show invites you on, live, during drive time.
- **PRO_337 The Practice Routine**: Your college routine isn't working at this level, and you need a new one by Sunday.
- **PRO_338 The Equipment Upgrade**: A sales rep wants you on expensive new training equipment, with a price to match.
- **PRO_339 The First Contract Question**: A reporter asks whether you expect an extension, and you haven't kicked a regular-season game.
- **PRO_340 The Teammate's Struggle**: A fellow rookie is falling apart, and nobody else seems to notice.
- **PRO_341 The Family Expectations**: Your family expects more now that you're earning, and they're not shy about it.
- **PRO_342 The Unexpected Bill**: A costly bill arrives at the worst possible time.
- **PRO_343 The Former Coach Calls**: Your old college coach calls to check in, and asks how you're really doing.
- **PRO_344 The Community Invitation**: A local school asks you to speak to its athletes.
- **PRO_345 The Dating Question**: Someone you meet seems more interested in the league than in you.
- **PRO_346 The Teammate's Celebration**: The locker room has a social scene, and you have to decide how far into it you want to go.
- **PRO_347 The Position Meeting**: Your place on the depth chart comes up in a meeting you weren't invited to.
- **PRO_348 The New Playbook**: A new coaching staff installs a new playbook and new expectations for the specialists.
- **PRO_349 The Rookie Comparison**: The media compare you with another young kicker, every week, by name.
- **PRO_350 The Charity Donation**: A family member asks you to donate to a cause back home.
- **PRO_351 The Teammate's Advice**: A veteran explains, very calmly, how fast a career can end.
- **PRO_352 The Agent's Warning**: Your agent warns you to be careful about where you're seen in public.
- **PRO_353 The Apartment Neighbor**: Your neighbor's schedule and yours are at war, and the walls are thin.
- **PRO_354 The Unexpected Criticism**: Fans tear into you online after one bad week of practice clips.
- **PRO_355 The Second Contract Conversation**: Your agent starts talking about what your next contract could look like, if you last.
- **PRO_356 The Veteran's Rules**: The veterans post the locker room's unwritten rules, and one of them is about you.
- **PRO_551 The Playbook Test**: The special teams coordinator quizzes the rookies on the playbook, out loud, at 7 a.m.
- **PRO_552 Learning the Snap Count**: The long snapper's rhythm is different from anything in college, and practice is tomorrow.
- **PRO_553 The Wind Tunnel**: The stadium's wind swirls in a way no film can show, and the veterans just laugh about it.
- **PRO_554 The Scout Team**: You spend practice kicking for the scout team, and nobody watches.
- **PRO_555 The Weight Room Pecking Order**: The weight room has a pecking order, and rookies lift last.
- **PRO_556 The Equipment Manager**: The equipment manager can make your life easy or miserable, and you haven't said hello yet.
- **PRO_557 The First Fine**: You're fined for a dress-code violation you didn't know existed.
- **PRO_558 The Meal Money**: The per diem envelope on the first road trip is thicker than your college scholarship check.
- **PRO_559 Rookie Year Taxes**: Your first tax bill as a pro is a number nobody prepared you for.
- **PRO_560 Free Cleats**: A shoe company offers free cleats and a small contract, if you wear them on camera.
- **PRO_561 The Kicking Ball Room**: The equipment staff prepares the game balls, and you have opinions about them.
- **PRO_562 The Trainer's Table**: The athletic trainer says your hip flexor is tight, and you think it's nothing.
- **PRO_563 Your First Locker**: Your name on tape above a locker between two veterans who haven't introduced themselves.
- **PRO_564 The Group Text**: The specialists have a group text, and you're not in it yet.
- **PRO_565 The Ride to Practice**: You don't have a car yet, and the veteran who offered rides keeps forgetting.
- **PRO_566 The Rookie Show**: The rookies have to put on a talent show for the veterans.
- **PRO_567 The Fan Event**: A season-ticket holders' event, and everyone wants a picture with the new kicker.
- **PRO_568 The Hometown Paper**: Your hometown paper runs a story about you with a photo from your senior prom.
- **PRO_569 The Card Signing**: A trading card company wants your signature on a thousand cards in one afternoon.
- **PRO_570 The Holder Who Won't Talk**: Your new holder is all business and doesn't talk to rookies.
- **PRO_571 The First Night Game**: The first night game under the lights, and you can't sleep the night before.
- **PRO_572 Sleeping on the Plane**: The team plane at midnight, and you can't sleep on planes.
- **PRO_573 The Hotel Roommate**: Your road roommate snores, sleepwalks and talks about his ex all night.
- **PRO_574 The Waiver Wire**: A rookie from your class is cut and claimed by another club within an hour.
- **PRO_575 The Rookie Contract**: You finally read your rookie contract all the way through.
- **PRO_576 The Kicker Down the Hall**: The punter is your age and acts like he's been here twenty years.
- **PRO_577 The Film You Hate**: You watch your own college film with the coaches, and it looks different now.
- **PRO_578 Your Parents in the Stands**: {parent} drives eleven hours to see you kick in person for the first time.
- **PRO_579 The Sibling Who Wants to Visit**: {sibling} wants to spend his spring break at your apartment.
- **PRO_580 The College Teammates' Chat**: Your old college teammates' group chat wants inside stories.
- **PRO_581 The Old Girlfriend**: Someone from college messages you the week your first big headline runs.
- **PRO_582 Your First Bad Practice Week**: Five bad practices in a row, and the coaches have stopped saying 'next one'.
- **PRO_583 The Veteran's Car**: A veteran tosses you his keys and asks you to move his car, which costs more than your house back home.
- **PRO_584 Learning to Cook**: Your first apartment, and your diet is cereal and takeout.
- **PRO_585 The Team Nutritionist**: The team nutritionist reviews what you eat and doesn't hide her reaction.
- **PRO_586 The Sleep Study**: The club puts every rookie through a sleep study, and the results are embarrassing.
- **PRO_587 The Team Psychologist**: The club's sports psychologist offers you a standing Tuesday appointment.
- **PRO_588 The Rookie Who Doesn't Make It**: The rookie you came in with is released after his first season.
- **PRO_589 The Practice-Field Fan**: A kid watches every practice from behind the fence and holds up a sign with your name.
- **PRO_590 Kicks for the Hospital**: The club runs a kick-a-thon for a children's hospital, and you're the main event.
- **PRO_591 The Night Before Your Debut**: The night before your first regular-season game, and your phone won't stop buzzing.
- **PRO_592 The Debut Week Interview**: The national broadcast crew wants five minutes with the rookie kicker.
- **PRO_593 The Team Photo**: The team photo, and you're in the back row next to a lineman who's never learned your name.
- **PRO_594 The Rookie Payday Dinner**: Your rookie class decides to celebrate your first full paycheck together.
- **PRO_595 The Trainer's Warning**: A trainer warns you about the supplements a veteran keeps recommending.
- **PRO_596 The Rookie Who Talks Too Much**: A rookie in your class keeps leaking locker room jokes online.
- **PRO_597 The Specialist Meeting Room**: The specialists' meeting room is the size of a closet, and three of you share it.
- **PRO_598 The Wrong Bus**: You get on the wrong team bus after a road practice and end up at the airport alone.
- **PRO_599 Your First Billboard**: Your face goes up on a billboard by the highway, and you drive past it twice.
- **PRO_600 The Veteran's Retirement Party**: A veteran you barely know retires, and you're expected at the party.
- **PRO_601 The Mentor Who Leaves**: The veteran who took you under his wing is traded to another club.
- **PRO_602 The Agent's Other Rookies**: Your agent has four rookie clients, and you can tell you're fourth.
- **PRO_603 The Practice Squad Promotion**: A friend from the practice squad is promoted to the active roster.
- **PRO_604 The Bad Haircut**: The rookies get haircuts from the veterans, whether they want them or not.
- **PRO_605 The Family Group Chat**: Your family group chat has become a running commentary on your career.
- **PRO_606 The Fantasy Football Message**: A stranger messages you about his fantasy team, and he's angry.
- **PRO_607 Your First Credit Card Bill**: Your first credit card statement as a pro, and you don't remember half the charges.
- **PRO_608 The Gym Membership**: A fancy gym offers you a free membership if you post about it.
- **PRO_609 The Kicking Coach From College**: Your college kicking coach wants to come watch a practice.
- **PRO_610 The Cold-Weather City**: Your first winter in a cold-weather city, and the ball feels like a rock.
- **PRO_611 The Hot-Weather Road Game**: A road game in a city where it's ninety degrees in December.
- **PRO_612 The Long Flight**: A five-hour flight to a road game, and the veterans play cards the whole way.
- **PRO_613 The Jersey Number**: You don't get the number you wore in college, and someone else wants it anyway.
- **PRO_614 The Rookie Quiz**: The coaches give the rookies a quiz on the club's history.
- **PRO_615 The Holiday Away From Home**: Your first holiday away from family, in a hotel near the stadium.
- **PRO_616 The Team Thanksgiving**: The veterans host a holiday dinner for the young players who can't go home.
- **PRO_617 The Teammate's Baby**: A teammate's baby is born on a game week, and the whole locker room celebrates.
- **PRO_618 The Rookie Year Review**: {coach} sits you down for an honest review of your first season.
- **PRO_619 The Offseason Without Structure**: For the first time in your life, nobody tells you what to do all summer.
- **PRO_620 The Old College Rival**: A kicker you competed against in college is now on a rival club.
- **PRO_621 The Rookie Hazing Report**: A reporter asks you, on the record, about the rookie traditions.
- **PRO_622 The Fan Who Sends Gifts**: A fan sends gifts to the facility every week, and they're getting stranger.
- **PRO_623 Your First Endorsement Shoot**: The commercial shoot takes eleven hours for fifteen seconds.
- **PRO_624 The Rookie Who Wants Your Spot**: An undrafted kicker in camp keeps showing up early and kicking where you can see.
- **PRO_625 The New Club as a Rookie**: Released after your first camp and signed somewhere new, you start your rookie year over.
- **PRO_626 The First Time You Hear Boos**: Fans boo at a practice open to the public, and you know who they mean.
- **PRO_627 The Phone Call Home**: You call home every Sunday, and this Sunday you don't know what to say.
- **PRO_628 The Rookie Paycheck Math**: You do the math on your rookie contract and realize how short a career really is.
- **PRO_629 The Rookie Who Calls Home Crying**: A rookie in your class calls home after every practice, and the veterans have noticed.

## Era 2: Settled In (26-29) (150)

| ID | Title | Window | Kind | Opens on | Sets | Callbacks (locked choices) | Waits on |
|---|---|---|---|---|---|---|---|
| PRO_021 | Don't Talk About It | age 26-29 | once | fg_streak 6+ |  |  |  |
| PRO_026 | The Coach for Hire | age 26-29, offseason | once |  | hired_private_coach | vetted_trainer, trained_with_alum | R3 money values |
| PRO_031 | The Incentive Clause | age 26-29 | once |  |  |  | R3 money values |
| PRO_032 | The Kicker Brought In | age 26-29, weeks 1-3 | variant |  |  |  |  |
| PRO_035 | The Bad Week | age 26-29 | once |  |  |  |  |
| PRO_037 | Contract Year: The Payday | age 26-29 | variant | contract_year |  |  |  |
| PRO_040 | The Hometown Discount | age 26-29 | once | contract_year |  |  | R3 money values |
| PRO_041 | The Holdout Talk | age 26-29 | once | contract_year |  |  |  |
| PRO_048 | The Agent's Bigger Client | age 26-29 | once |  | agent_neglect |  |  |
| PRO_052 | The Teammate Traded Away | age 26-29 | once |  |  |  |  |
| PRO_056 | The Big Check | age 26-29 | once |  | saved_big_check, spent_big_check |  | R3 money values |
| PRO_061 | The Restaurant | age 26-29 | once |  | opened_restaurant |  | R3 money values |
| PRO_064 | The Friend's Start-Up | age 26-29 | once |  | invested_in_friend |  | R3 money values |
| PRO_069 | {parent}'s House | age 26-29 | once |  |  | helped_family_financially | R3 money values |
| PRO_077 | First Day of School | age 26-29 | once | became_parent |  |  |  |
| PRO_080 | {parent} Is Getting Older | age 26-29 | once |  |  |  |  |
| PRO_082 | {sibling}'s Own Shot | age 26-29 | once |  |  | went_home_for_dad, came_clean_tape |  |
| PRO_086 | {tyler} Gets Cut | age 26-29 | once |  |  |  |  |
| PRO_090 | The Holder's Last Season | age 26-29 | once |  |  |  |  |
| PRO_091 | The Snapper Retires | age 26-29 | once | trusted_snapper |  |  |  |
| PRO_093 | The Concussion | age 26-29 | once |  |  |  |  |
| PRO_098 | A College Teammate's Wedding | age 26-29, offseason | once |  |  | roommate_pact, roommate_cold_war |  |
| PRO_101 | The Veteran Who Can't Let Go | age 26-29 | once |  |  |  |  |
| PRO_102 | The Players-Only Meeting | age 26-29 | once |  |  |  |  |
| PRO_103 | The Player Rep | age 26-29 | once |  | player_rep |  |  |
| PRO_105 | The Injured Teammate | age 26-29 | once |  |  |  |  |
| PRO_107 | The Podcast | age 26-29 | once | tier verified |  |  |  |
| PRO_110 | The National Deal | age 26-29 | once | tier verified |  |  |  |
| PRO_111 | The Leak | age 26-29 | once |  |  |  |  |
| PRO_179 | The Prime Slump | age 26-29 | variant | slump_now 1+ |  | saw_sports_psych, leaned_on_support |  |
| PRO_184 | Untouchable | age 26-29 | variant | fg_streak 8+ |  |  |  |
| PRO_192 | Hurt in Your Prime | age 26-29 | variant | injured_now 1+ |  | committed_to_recovery, hid_injury |  |
| PRO_196 | A New City, Mid-Career | age 26-29 | variant | signed_new_club |  |  |  |
| PRO_202 | The Rookie Asks | age 26-29 | repeat |  |  |  |  |
| PRO_272 | Wedding Season | age 26-29, offseason | once |  |  |  |  |
| PRO_273 | The Offseason Surgery | age 26-29, offseason | once |  |  |  |  |
| PRO_274 | The Training Partner | age 26-29, offseason | once |  |  |  |  |
| PRO_275 | The Class | age 26-29, offseason | once |  |  | finished_degree_track |  |
| PRO_277 | Moving House | age 26-29, offseason | once | made_long_distance_work / committed_to_relationship / new_partner / engaged / married |  |  |  |
| PRO_278 | The Summer Without Football | age 26-29, offseason | once |  |  |  |  |
| PRO_283 | The Hometown Parade | offseason | once | pro_seasons 3+ |  |  |  |
| PRO_284 | The Kicking Coach Calls | age 26-29, offseason | once |  |  |  |  |
| PRO_285 | The Charity Golf Event | age 26-29, offseason | once |  |  |  |  |
| PRO_288 | The Off-Season Weight | age 26-29, offseason | once |  |  |  |  |
| PRO_309 | The Captaincy | any | once | pro_seasons 5+ | pro_captain |  |  |
| PRO_310 | The Big Second Contract | any | once | re_signed; pro_seasons 4+ |  |  | R3 money values |
| PRO_311 | The Teammate Who Becomes a Coach | any | once | pro_seasons 6+ |  |  |  |
| PRO_312 | The Endorsement Renewal | any | once | tier verified; pro_seasons 5+ |  |  |  |
| PRO_313 | The Hometown Charity Game | offseason | once | pro_seasons 5+ |  |  |  |
| PRO_314 | The Rival Club Calls | any | once | contract_year; pro_seasons 5+ |  |  |  |
| PRO_315 | The Motivation Slump | any | once | pro_seasons 6+ |  |  |  |
| PRO_316 | The Kid Who Copies Your Routine | any | once | pro_seasons 5+ |  |  |  |
| PRO_317 | A Teammate Holds Out | any | once | pro_seasons 4+ |  |  |  |
| PRO_318 | The Coordinator's Son | any | once | pro_seasons 5+ |  |  |  |
| PRO_320 | The Prime-Time Game | any | once | pro_seasons 4+ |  |  |  |
| PRO_357 | The Contract Extension | age 26-29 | once |  |  |  |  |
| PRO_358 | The First Big Purchase | age 26-29 | once |  |  |  | R3 money values |
| PRO_359 | The Regional Endorsement | age 26-29 | once |  |  |  | R3 money values |
| PRO_360 | The Investment Pitch | age 26-29 | once |  |  |  | R3 money values |
| PRO_361 | The Rookie Mentor | age 26-29 | once |  |  |  |  |
| PRO_362 | The Locker Room Reputation | age 26-29 | once |  |  |  |  |
| PRO_363 | The Coaching Change | age 26-29 | once |  |  |  |  |
| PRO_364 | The Public Relationship | age 26-29 | once | made_long_distance_work / committed_to_relationship / new_partner / engaged / married |  |  |  |
| PRO_365 | The First Home Repair | age 26-29 | once |  |  |  | R3 money values |
| PRO_366 | The Charity Commitment | age 26-29 | once |  |  |  |  |
| PRO_367 | The Radio Segment | age 26-29 | once |  |  |  |  |
| PRO_368 | The Offseason Vacation | age 26-29, offseason | once | made_long_distance_work / committed_to_relationship / new_partner / engaged / married |  |  |  |
| PRO_369 | The Former Teammate | age 26-29 | once |  |  |  |  |
| PRO_370 | The New Neighborhood | age 26-29 | once |  |  |  |  |
| PRO_371 | The Financial Mistake | age 26-29 | once |  |  |  | R3 money values |
| PRO_372 | The Family Conversation | age 26-29 | once | made_long_distance_work / committed_to_relationship / new_partner / engaged / married |  |  |  |
| PRO_373 | The Family Business | age 26-29 | once |  | family_business |  | R3 money values |
| PRO_374 | The Memorabilia Deal | age 26-29 | once |  |  |  | R3 money values |
| PRO_375 | The Young Kicker's Question | age 26-29 | once |  |  |  |  |
| PRO_376 | The Retirement Savings | age 26-29 | once |  |  |  | R3 money values |
| PRO_377 | The Public Appearance | age 26-29 | once |  |  |  |  |
| PRO_378 | The Family Holiday | age 26-29 | once |  |  |  |  |
| PRO_379 | The Teammates' Dispute | age 26-29 | once |  |  |  |  |
| PRO_380 | The Sponsored Posts | age 26-29 | once | tier verified |  |  |  |
| PRO_381 | The Long-Term Commitment | age 26-29 | once | made_long_distance_work / committed_to_relationship / new_partner / engaged / married |  |  |  |
| PRO_382 | The Injury Prevention Program | age 26-29 | once |  |  |  |  |
| PRO_383 | The Younger Teammate's Mistake | age 26-29 | once |  |  |  |  |
| PRO_384 | The Personal Trainer | age 26-29 | once |  |  |  | R3 money values |
| PRO_385 | Dinner With Influential People | age 26-29 | once |  |  |  |  |
| PRO_386 | The Homecoming Event | age 26-29, offseason | once |  |  |  |  |
| PRO_387 | The Team's Future | age 26-29 | once |  |  |  |  |
| PRO_388 | The New Family Responsibility | age 26-29 | once |  |  |  |  |
| PRO_389 | The Offseason Media Tour | age 26-29, offseason | once |  |  |  |  |
| PRO_390 | The Career Milestone | age 26-29 | once | pro_seasons 4+ |  |  |  |
| PRO_630 | The Fourth Season | age 26-29 | once |  |  |  |  |
| PRO_631 | The Comfortable Routine | age 26-29 | once |  |  |  |  |
| PRO_632 | The Raise | age 26-29 | once |  |  |  | R3 money values |
| PRO_633 | The House With a Yard | age 26-29 | once |  |  |  | R3 money values |
| PRO_634 | The Specialist Who Retires | age 26-29 | once |  |  |  |  |
| PRO_635 | A Different Snap | age 26-29 | once |  |  |  |  |
| PRO_636 | The Pregnancy | age 26-29 | once | made_long_distance_work / committed_to_relationship / new_partner / engaged / married |  |  |  |
| PRO_637 | The Baby's First Year | age 26-29 | once | became_parent |  |  |  |
| PRO_638 | The Daycare | age 26-29 | once | became_parent |  |  |  |
| PRO_639 | The In-Laws | age 26-29 | once | made_long_distance_work / committed_to_relationship / new_partner / engaged / married |  |  |  |
| PRO_640 | The Kicking Video Series | age 26-29 | once | tier verified |  |  |  |
| PRO_641 | The Podcast Guest Spot | age 26-29 | once |  |  |  |  |
| PRO_642 | The Teammate Who Becomes a Friend | age 26-29 | once |  |  |  |  |
| PRO_643 | The Holder's Wedding | age 26-29 | once |  |  |  |  |
| PRO_644 | The Fan Club | age 26-29 | once |  |  |  |  |
| PRO_645 | The Rival's Big Contract | age 26-29 | once |  |  |  |  |
| PRO_646 | The Charity Golf Tournament | age 26-29 | once |  |  |  |  |
| PRO_647 | The Investment Club | age 26-29 | once |  |  |  | R3 money values |
| PRO_648 | The Second Car | age 26-29 | once |  |  |  | R3 money values |
| PRO_649 | The Contract Rumors | age 26-29 | once |  |  |  |  |
| PRO_650 | The Locker Room Elections | age 26-29 | once |  |  |  |  |
| PRO_651 | The Mid-Career Injury | age 26-29 | once |  |  |  |  |
| PRO_652 | The Rehab Partner | age 26-29 | once |  |  |  |  |
| PRO_653 | The Long Offseason | age 26-29, offseason | once |  |  |  |  |
| PRO_654 | The Hometown Kids' Camp | age 26-29, offseason | once |  |  |  |  |
| PRO_655 | The Mortgage | age 26-29 | once |  |  |  | R3 money values |
| PRO_656 | The Family Health Scare | age 26-29 | once |  |  |  |  |
| PRO_657 | The Teammate's Divorce | age 26-29 | once |  |  |  |  |
| PRO_658 | The Charity Auction | age 26-29 | once |  |  |  |  |
| PRO_659 | The Brand Ambassador | age 26-29 | once |  |  |  | R3 money values |
| PRO_660 | The Kicker Clinic Tour | age 26-29 | once |  |  |  | R3 money values |
| PRO_661 | A New Boss on the Sideline | age 26-29 | once |  |  |  |  |
| PRO_662 | The Team Leader Talk | age 26-29 | once |  |  |  |  |
| PRO_663 | The Team Trip Abroad | age 26-29 | once |  |  |  |  |
| PRO_664 | The Jet Lag Game | age 26-29 | once |  |  |  |  |
| PRO_665 | The Contract Bonus | age 26-29 | once |  |  |  | R3 money values |
| PRO_666 | The Wedding Planning | age 26-29 | once | engaged; not married |  |  |  |
| PRO_667 | The House Party You Host | age 26-29 | once |  |  |  |  |
| PRO_668 | Your Old Coach Visits | age 26-29 | once |  |  |  |  |
| PRO_669 | The Ball Boy | age 26-29 | once |  |  |  |  |
| PRO_670 | The Scrapbook | age 26-29 | once |  |  |  |  |
| PRO_671 | The Fan Who Grew Up | age 26-29 | once |  |  |  |  |
| PRO_672 | The Fitness Test | age 26-29, offseason | once |  |  |  |  |
| PRO_673 | The Pet | age 26-29 | once |  |  |  |  |
| PRO_674 | The Retirement Account | age 26-29 | once |  |  |  | R3 money values |
| PRO_675 | The Charity Basketball Game | age 26-29 | once |  |  |  |  |
| PRO_676 | Supporting a Teammate's Cause | age 26-29 | once |  |  |  |  |
| PRO_677 | The Old Rival on Your Team | age 26-29 | once |  |  |  |  |
| PRO_678 | The Brother's Wedding | age 26-29 | once |  |  |  |  |
| PRO_679 | The City Starts to Feel Like Home | age 26-29 | once |  |  |  |  |
| PRO_680 | The Sponsor's Event | age 26-29 | once |  |  |  |  |
| PRO_681 | The Mid-Career Check-In | age 26-29 | once |  |  |  |  |
| PRO_682 | The Teammate Who Gets Rich | age 26-29 | once |  |  |  |  |
| PRO_683 | The Practice Squad Kicker | age 26-29 | once |  |  |  |  |
| PRO_684 | The Kicking Net in the Living Room | age 26-29 | once | made_long_distance_work / committed_to_relationship / new_partner / engaged / married |  |  |  |
| PRO_685 | The Season-Ticket Holder | age 26-29 | once |  |  |  |  |
| PRO_686 | The Charity Visit You Remember | age 26-29 | once |  |  |  |  |
| PRO_687 | The Coaching Staff Dinner | age 26-29 | once |  |  |  |  |
| PRO_688 | The Big Market Rumor | age 26-29 | once |  |  |  |  |
| PRO_689 | The Weather Delay | age 26-29 | once |  |  |  |  |
| PRO_690 | The Players' Council | age 26-29 | once |  |  |  |  |

- **PRO_021 Don't Talk About It**: The specialists have a superstition: nobody says the streak out loud. A rookie just said it.
- **PRO_026 The Coach for Hire**: A private coach who rebuilt three pro kickers offers you his offseason, for a price.
- **PRO_031 The Incentive Clause**: Your contract pays a bonus if you hit 90 percent this season, and your agent keeps texting you the math.
- **PRO_032 The Kicker Brought In**: The club signs a kicker with a bigger leg and a lower salary, and puts him at the locker next to yours. *(Prime-age version; PRO_133 is the veteran version.)*
- **PRO_035 The Bad Week**: You snapped at {holder}, ignored {coach} and skipped the team meal. It's been that kind of week.
- **PRO_037 Contract Year: The Payday**: This is the contract that sets up your family for life, if you earn it this season.
- **PRO_040 The Hometown Discount**: The club offers less than the market, and asks you to take it because you're family here.
- **PRO_041 The Holdout Talk**: Your agent says the only way to get paid is to stay home from camp. *(A temptation, not a mechanic: the game has no holdouts. Holding firm costs retention and the coach.)*
- **PRO_048 The Agent's Bigger Client**: Your agent just signed a star quarterback, and your calls go to voicemail.
- **PRO_052 The Teammate Traded Away**: The club traded your holder's best friend at midnight. He found out from his phone. *(Other players get traded; the player can't be.)*
- **PRO_056 The Big Check**: The signing bonus clears. Your phone lights up with cousins.
- **PRO_061 The Restaurant**: An old college teammate wants your name and your money on a steakhouse downtown. He has a chef, a location and a business plan he wrote last night.
- **PRO_064 The Friend's Start-Up**: {best_friend} is starting a company and asks you to be the first investor.
- **PRO_069 {parent}'s House**: You could pay off {parent}'s mortgage this week. He's told you not to, twice.
- **PRO_077 First Day of School**: Your kid's first day of school is a Thursday practice.
- **PRO_080 {parent} Is Getting Older**: {parent} forgets the name of a neighbor he's known for twenty years.
- **PRO_082 {sibling}'s Own Shot**: {sibling} has a tryout of his own, and he wants you there.
- **PRO_086 {tyler} Gets Cut**: {tyler} is released on a Monday. He calls you before his agent.
- **PRO_090 The Holder's Last Season**: {holder} is retiring after this season and wants every hold to count.
- **PRO_091 The Snapper Retires**: The long snapper you've trusted for years is done, and he asks you to speak at his farewell.
- **PRO_093 The Concussion**: A teammate who has had too many concussions is hiding another one, and you saw it happen.
- **PRO_098 A College Teammate's Wedding**: Your old college roommate is getting married, and he wants you to give a toast.
- **PRO_101 The Veteran Who Can't Let Go**: A thirty-six-year-old linebacker is getting cut, and he hasn't figured it out yet.
- **PRO_102 The Players-Only Meeting**: The team captains call a meeting about the coach, and they want your vote.
- **PRO_103 The Player Rep**: The team needs a union representative, and nobody wants to be the one management remembers.
- **PRO_105 The Injured Teammate**: A teammate who tore his knee for the team is cut the day he's cleared to practice.
- **PRO_107 The Podcast**: A popular podcast wants you for an hour. The host is known for getting athletes to say too much.
- **PRO_110 The National Deal**: A national brand wants you for a commercial that would play during every game this year.
- **PRO_111 The Leak**: Someone is leaking locker-room conversations to a reporter, and the coaches think it's a specialist.
- **PRO_179 The Prime Slump**: You're supposed to be at your best, and the misses in practice have started making headlines.
- **PRO_184 Untouchable**: The streak is the longest in the league, and the other team's kicker is asking you for tips.
- **PRO_192 Hurt in Your Prime**: A hip flexor in the best season of your career, and the club wants to know how long.
- **PRO_196 A New City, Mid-Career**: A new club, a new town, and a locker room that has already decided whether you're a mercenary.
- **PRO_202 The Rookie Asks**: A rookie specialist corners you after practice with a question you used to ask. *(Repeatable (15-week cooldown). Locked choices open with experience: min pro_seasons 3 / 6 / 10, age, earlier flags.)*
- **PRO_272 Wedding Season**: Four friends are getting married this summer, and every one of them wants you to give a toast.
- **PRO_273 The Offseason Surgery**: The doctors say a small surgery now saves your next three seasons. The recovery takes the whole summer.
- **PRO_274 The Training Partner**: A young kicker from a rival club asks to train with you this summer.
- **PRO_275 The Class**: You sign up for a class at the community college, something that has nothing to do with football.
- **PRO_277 Moving House**: You're buying a house, and every room is an argument about how long you'll stay in this city.
- **PRO_278 The Summer Without Football**: For one offseason, you put the bag in the closet and don't touch a ball for six weeks.
- **PRO_283 The Hometown Parade**: Your hometown throws you a parade after your best season. {parent} rides in the front car.
- **PRO_284 The Kicking Coach Calls**: Your old private kicking coach calls with an idea about your plant foot.
- **PRO_285 The Charity Golf Event**: The club's charity golf event, with donors, owners and one teammate who's had too much sun.
- **PRO_288 The Off-Season Weight**: You come back from the off-season heavier than the club likes, and the strength coach has a scale ready.
- **PRO_309 The Captaincy**: The team votes for captains, and for the first time a kicker is on the ballot.
- **PRO_310 The Big Second Contract**: Your agent says this is the contract that matters, and the club agrees, eventually.
- **PRO_311 The Teammate Who Becomes a Coach**: Your holder retires and joins the coaching staff. Now they're your boss.
- **PRO_312 The Endorsement Renewal**: Your biggest sponsor wants to renew, with new conditions.
- **PRO_313 The Hometown Charity Game**: You organize a charity game in your hometown with players from five clubs.
- **PRO_314 The Rival Club Calls**: A rival club's general manager makes it clear they'd pay more, next time you're free.
- **PRO_315 The Motivation Slump**: Nothing's wrong. That's the problem: practice feels like a job, and the job feels like nothing.
- **PRO_316 The Kid Who Copies Your Routine**: A high school kicker's video goes around: he copies your routine down to the last step.
- **PRO_317 A Teammate Holds Out**: Your closest teammate is holding out for a new contract, and wants you to say something publicly.
- **PRO_318 The Coordinator's Son**: The new special teams coordinator's son is a kicker on the practice squad.
- **PRO_320 The Prime-Time Game**: Your first prime-time game in years, and the broadcast crew wants an interview at the hotel.
- **PRO_357 The Contract Extension**: The club wants to talk about extending your contract, a year early.
- **PRO_358 The First Big Purchase**: You can finally afford the car you've wanted since high school.
- **PRO_359 The Regional Endorsement**: A regional company offers you a sponsorship worth more than your rookie salary.
- **PRO_360 The Investment Pitch**: Someone pitches you an investment that sounds too good, and they know it.
- **PRO_361 The Rookie Mentor**: The club asks you to help a younger player adjust, the way someone helped you.
- **PRO_362 The Locker Room Reputation**: Younger teammates have started looking at you when something goes wrong.
- **PRO_363 The Coaching Change**: A new special teams coach arrives with a new way of doing everything.
- **PRO_364 The Public Relationship**: Your relationship becomes a topic of public interest, and {love_interest} didn't sign up for that.
- **PRO_365 The First Home Repair**: The roof leaks the week of a road trip, and the bill is enormous.
- **PRO_366 The Charity Commitment**: A nonprofit asks you to become a regular supporter, not just a photo.
- **PRO_367 The Radio Segment**: You're offered a recurring weekly segment on sports radio.
- **PRO_368 The Offseason Vacation**: {love_interest} wants a real vacation; you want to train.
- **PRO_369 The Former Teammate**: A former teammate can't find another job in the league and keeps calling.
- **PRO_370 The New Neighborhood**: You can get involved in your neighborhood or stay a stranger on your own street.
- **PRO_371 The Financial Mistake**: An investment or a purchase wasn't as smart as it looked.
- **PRO_372 The Family Conversation**: You and {love_interest} talk about starting a family, and neither of you knows the right time.
- **PRO_373 The Family Business**: A relative wants your money and your name to expand the family business.
- **PRO_374 The Memorabilia Deal**: A collector wants to pay you to sign five hundred footballs.
- **PRO_375 The Young Kicker's Question**: A college kicker emails you for career advice, and it's a good question.
- **PRO_376 The Retirement Savings**: A financial advisor reviews your long-term plan and asks a question you can't answer.
- **PRO_377 The Public Appearance**: You're asked to attend a high-profile event in a suit you don't own yet.
- **PRO_378 The Family Holiday**: The schedule lands on a family holiday again.
- **PRO_379 The Teammates' Dispute**: Two teammates ask you to settle an argument, which means picking a side.
- **PRO_380 The Sponsored Posts**: A company offers to pay for sponsored posts, and the product is fine, mostly.
- **PRO_381 The Long-Term Commitment**: {love_interest} wants to talk about where you'll live after football.
- **PRO_382 The Injury Prevention Program**: The club wants you on a new training and recovery routine.
- **PRO_383 The Younger Teammate's Mistake**: A rookie makes a mistake and comes to you, not the coaches.
- **PRO_384 The Personal Trainer**: A private trainer could change your offseason, for a price.
- **PRO_385 Dinner With Influential People**: Your agent invites you to dinner with influential people in the league.
- **PRO_386 The Homecoming Event**: Your high school invites you back for its homecoming.
- **PRO_387 The Team's Future**: The franchise is talking about a full rebuild, and your name is on a list.
- **PRO_388 The New Family Responsibility**: A family member needs more of your time than the season has.
- **PRO_389 The Offseason Media Tour**: Your growing reputation comes with an offseason full of interviews.
- **PRO_390 The Career Milestone**: You reach a milestone and have to decide how to celebrate it.
- **PRO_630 The Fourth Season**: Your fourth pro season, and nobody calls you a rookie anymore.
- **PRO_631 The Comfortable Routine**: Your routine works so well it's starting to feel like a rut.
- **PRO_632 The Raise**: Your second contract is real money, and everyone you know has noticed.
- **PRO_633 The House With a Yard**: You buy a house with a yard big enough for a kicking net.
- **PRO_634 The Specialist Who Retires**: The punter you've worked beside for years retires suddenly.
- **PRO_635 A Different Snap**: A new long snapper, and your timing is off for the first time in years.
- **PRO_636 The Pregnancy**: {love_interest} is pregnant, and the due date is in the middle of the season.
- **PRO_637 The Baby's First Year**: Sleepless nights with a newborn during the season.
- **PRO_638 The Daycare**: Finding daycare in a city where you might not live next year.
- **PRO_639 The In-Laws**: {love_interest}'s family visits for two weeks during the season.
- **PRO_640 The Kicking Video Series**: You start a video series teaching kids how to kick.
- **PRO_641 The Podcast Guest Spot**: A podcast wants you every week, and the host likes controversy.
- **PRO_642 The Teammate Who Becomes a Friend**: A teammate becomes your closest friend in the league.
- **PRO_643 The Holder's Wedding**: {holder} asks you to be in the wedding party.
- **PRO_644 The Fan Club**: Fans start an official fan club, and they want you at the first meeting.
- **PRO_645 The Rival's Big Contract**: {tyler} signs a bigger contract than yours, and the media want a comment.
- **PRO_646 The Charity Golf Tournament**: You host a charity golf tournament for the first time.
- **PRO_647 The Investment Club**: A group of teammates forms an investment club and wants you in.
- **PRO_648 The Second Car**: You buy a second car, and then realize you never drive the first one.
- **PRO_649 The Contract Rumors**: Rumors say the club might not re-sign you next spring.
- **PRO_650 The Locker Room Elections**: The players' union asks you to run for team representative.
- **PRO_651 The Mid-Career Injury**: The first serious injury of your career, in your prime.
- **PRO_652 The Rehab Partner**: You rehab alongside a teammate with the same injury.
- **PRO_653 The Long Offseason**: The longest offseason of your career, and you don't know what to do with it.
- **PRO_654 The Hometown Kids' Camp**: You run a free camp for kids in your hometown.
- **PRO_655 The Mortgage**: Your first mortgage, and the papers are thicker than your playbook.
- **PRO_656 The Family Health Scare**: A family member gets scary news while you're on a road trip.
- **PRO_657 The Teammate's Divorce**: A teammate's divorce plays out in the locker room.
- **PRO_658 The Charity Auction**: You donate an experience to a charity auction, and the winner is very excited.
- **PRO_659 The Brand Ambassador**: A brand wants you as its regional ambassador for three years.
- **PRO_660 The Kicker Clinic Tour**: A kicking company wants you on a weekend clinic tour.
- **PRO_661 A New Boss on the Sideline**: A new head coach arrives and doesn't seem to think kickers matter.
- **PRO_662 The Team Leader Talk**: {coach} asks you to speak up more in team meetings.
- **PRO_663 The Team Trip Abroad**: The club plays a game overseas, and the trip is a week long.
- **PRO_664 The Jet Lag Game**: You're kicking in a different time zone, and your body hasn't noticed yet.
- **PRO_665 The Contract Bonus**: You hit a contract bonus, and your agent wants you to celebrate quietly.
- **PRO_666 The Wedding Planning**: Wedding planning during the season, and every decision is a phone call.
- **PRO_667 The House Party You Host**: You host a team party at your new house, and it gets bigger than planned.
- **PRO_668 Your Old Coach Visits**: Your college special teams coach visits practice and watches every kick.
- **PRO_669 The Ball Boy**: A ball boy who's been here as long as you have is going to college.
- **PRO_670 The Scrapbook**: {parent} keeps a scrapbook of every article about you, and shows you.
- **PRO_671 The Fan Who Grew Up**: A kid who held a sign at your first practice is now in high school and kicking.
- **PRO_672 The Fitness Test**: The club's offseason fitness test, and you're not where you were.
- **PRO_673 The Pet**: You get a dog, and it changes your schedule more than you expected.
- **PRO_674 The Retirement Account**: Your advisor finally gets you to open a retirement account.
- **PRO_675 The Charity Basketball Game**: A charity basketball game with teammates, and you're the worst player on the court.
- **PRO_676 Supporting a Teammate's Cause**: A teammate asks you to support his foundation.
- **PRO_677 The Old Rival on Your Team**: A kicker you competed with in college signs with your club as a backup.
- **PRO_678 The Brother's Wedding**: {sibling} is getting married on a game weekend.
- **PRO_679 The City Starts to Feel Like Home**: You realize you know your neighbors and your coffee order.
- **PRO_680 The Sponsor's Event**: Your sponsor wants you at an event on your only day off.
- **PRO_681 The Mid-Career Check-In**: Your agent asks where you want to be in five years.
- **PRO_682 The Teammate Who Gets Rich**: A teammate signs a huge contract and starts acting like it.
- **PRO_683 The Practice Squad Kicker**: The practice squad kicker is good, and the coaches know it.
- **PRO_684 The Kicking Net in the Living Room**: You set up a net in the living room, and {love_interest} has opinions.
- **PRO_685 The Season-Ticket Holder**: A season-ticket holder has sat behind the bench for thirty years and talks to you every week.
- **PRO_686 The Charity Visit You Remember**: A charity visit leaves a mark, and you can't stop thinking about one kid.
- **PRO_687 The Coaching Staff Dinner**: The coaches invite you to dinner, which they've never done before.
- **PRO_688 The Big Market Rumor**: A big-market club is rumored to want you next season.
- **PRO_689 The Weather Delay**: A long weather delay, and you have to stay warm for three hours.
- **PRO_690 The Players' Council**: The players form a leadership council, and you're on it.

## Era 3: Veteran (30-33) (150)

| ID | Title | Window | Kind | Opens on | Sets | Callbacks (locked choices) | Waits on |
|---|---|---|---|---|---|---|---|
| PRO_022 | The National List | age 30-33 | once | tier fan_favorite |  |  |  |
| PRO_023 | The Skills Contest | age 30-33 | once | tier fan_favorite |  |  |  |
| PRO_053 | A Coach Out of a Job | age 30-33 | once |  |  |  |  |
| PRO_054 | The General Manager's Nephew | age 30-33 | once |  |  |  |  |
| PRO_055 | Loyalty or the Paycheck | age 30-33 | once | contract_year |  | stayed_loyal, explored_options |  |
| PRO_063 | The Car Dealership | age 30-33 | once |  | dealership_partner |  | R3 money values |
| PRO_070 | The Foundation | age 30-33 | once |  | started_foundation |  | R3 money values |
| PRO_072 | Broke at Thirty-Three | age 30-33 | once | advisor_stole / bad_venture / spent_big_check / lived_large / hid_the_loss |  |  | R3 money values + savings check |
| PRO_073 | The Pension Meeting | age 30-33 | once |  |  |  | R3 money values |
| PRO_084 | The Coach Who Taught You | age 30-33, offseason | once |  |  | earned_coach_confidence, repaired_coach_trust |  |
| PRO_088 | The Rookie Kicker You Mentor | age 30-33 | once |  | mentored_rookie_kicker | mentored_backup, mentored_younger_student |  |
| PRO_094 | The Letter From a Kid | age 30-33 | once |  |  | community_volunteer |  |
| PRO_109 | The Awards Show | age 30-33 | once | tier fan_favorite |  |  |  |
| PRO_131 | Thirty | age 30 | once |  |  |  |  |
| PRO_132 | The Maintenance Bill | age 30-33 | once |  |  |  |  |
| PRO_219 | Someone New, Later | age 30-33 | once | divorced / broke_up_pro |  |  | R8 re-point {love_interest} |
| PRO_220 | The Second Wedding | age 30-33 | once | engaged + divorced |  |  | R8 re-point {love_interest} |
| PRO_221 | The Anniversary | age 30-33 | once | married |  |  |  |
| PRO_225 | {sibling}'s Family | age 30-33 | once |  |  |  |  |
| PRO_229 | The Radio Show | age 30-33 | once |  | radio_show |  |  |
| PRO_235 | A Franchise Offer | age 30-33 | once |  | franchise_owner |  | R3 money values |
| PRO_238 | The Comeback Year | age 30-33 | once | released / benched |  |  |  |
| PRO_256 | Who Am I Without It | age 30-33 | once | planning_retirement |  |  |  |
| PRO_270 | The Camp You Teach | age 30-33, offseason | once |  |  |  |  |
| PRO_271 | The Family Vacation | age 30-33, offseason | once | made_long_distance_work / committed_to_relationship / new_partner / engaged / married |  |  |  |
| PRO_276 | Back to Your College | age 30-33, offseason | once |  |  |  |  |
| PRO_279 | The Fan Convention | age 30-33, offseason | once | tier verified |  |  |  |
| PRO_280 | The Mountain Trip | age 30-33, offseason | once |  |  |  |  |
| PRO_286 | The Off-Season Job Offer | age 30-33, offseason | once |  |  |  |  |
| PRO_287 | Family Reunion, Pro Edition | age 30-33, offseason | once |  |  |  | R3 money values |
| PRO_292 | The Kicker You Grew Up Watching | any | once | pro_seasons 6+ |  |  |  |
| PRO_293 | The Rule Change | any | once | pro_seasons 8+ |  |  |  |
| PRO_297 | The Rookie Who Wears Your Number | any | once | pro_seasons 8+ |  |  |  |
| PRO_299 | The Coach You Outlasted | any | once | pro_seasons 8+ |  |  |  |
| PRO_319 | Ten Years | any | once | pro_seasons 10+ |  |  |  |
| PRO_391 | The Room Starts Looking at You | age 30-33 | once |  |  |  |  |
| PRO_392 | The Coaching Staff Meeting | age 30-33 | once |  |  |  |  |
| PRO_393 | The Family Schedule | age 30-33 | once | became_parent |  |  |  |
| PRO_394 | The Retirement Plan | age 30-33 | once |  |  |  | R3 money values |
| PRO_395 | The Former Teammate's Retirement | age 30-33 | once |  |  |  |  |
| PRO_396 | The Younger Generation | age 30-33 | once |  |  |  |  |
| PRO_397 | The New Contract Negotiation | age 30-33 | once |  |  |  |  |
| PRO_398 | The Media Debate | age 30-33 | once |  |  |  |  |
| PRO_399 | The Community Commitment | age 30-33 | once |  |  |  |  |
| PRO_400 | The Expensive Lifestyle | age 30-33 | once |  |  |  | R3 money values |
| PRO_401 | The Advisor's Concern | age 30-33 | once |  |  |  | R3 money values |
| PRO_402 | The Team Rebuild | age 30-33 | once |  |  |  |  |
| PRO_403 | The New Special Teams Coach | age 30-33 | once |  |  |  |  |
| PRO_404 | The Mentor's Retirement | age 30-33 | once |  |  |  |  |
| PRO_405 | The Old Rival | age 30-33 | once |  |  |  |  |
| PRO_406 | The Family Business Dispute | age 30-33 | once | opened_restaurant / dealership_partner / invested_in_friend / franchise_owner / family_business / business_owner |  |  |  |
| PRO_407 | The College Invitation | age 30-33 | once |  |  |  |  |
| PRO_408 | The Team's Direction | age 30-33 | once |  |  |  |  |
| PRO_409 | The New Home | age 30-33 | once | became_parent |  |  |  |
| PRO_410 | The Injury Prevention Debate | age 30-33 | once |  |  |  |  |
| PRO_411 | The Veteran's Committee | age 30-33 | once |  |  |  |  |
| PRO_412 | The Charity Board | age 30-33 | once |  |  |  |  |
| PRO_413 | The Business Partner's Exit | age 30-33 | once | opened_restaurant / dealership_partner / invested_in_friend / franchise_owner / family_business / business_owner |  |  |  |
| PRO_414 | Everyone Wants You There | age 30-33 | once |  |  |  |  |
| PRO_415 | The New Contract Structure | age 30-33 | once |  |  |  |  |
| PRO_416 | The Retirement Rumors | age 30-33 | once |  |  |  |  |
| PRO_417 | The Rookie's Confidence | age 30-33 | once |  |  |  |  |
| PRO_418 | The Former Coach's Advice | age 30-33 | once |  |  |  |  |
| PRO_419 | A Town's Thank-You | age 30-33 | once |  |  |  |  |
| PRO_420 | The Guest Analyst | age 30-33 | once |  |  |  |  |
| PRO_421 | The Family Financial Decision | age 30-33 | once | made_long_distance_work / committed_to_relationship / new_partner / engaged / married |  |  | R3 money values |
| PRO_422 | The Teammate's Contract | age 30-33 | once |  |  |  |  |
| PRO_423 | The Offseason Commitment | age 30-33, offseason | once |  |  |  |  |
| PRO_424 | The Hall of Fame Conversation | age 30-33 | once | pro_seasons 8+ |  |  |  |
| PRO_425 | The Young Kicker's Arrival | age 30-33 | once |  |  |  |  |
| PRO_426 | The Business Reputation | age 30-33 | once | opened_restaurant / dealership_partner / invested_in_friend / franchise_owner / family_business / business_owner |  |  |  |
| PRO_427 | The Team's Community Day | age 30-33 | once |  |  |  |  |
| PRO_428 | The Family Milestone | age 30-33 | once |  |  |  |  |
| PRO_429 | The Old Teammate's Request | age 30-33 | once |  | business_owner |  | R3 money values |
| PRO_430 | The Next Chapter Conversation | age 30-33 | once | made_long_distance_work / committed_to_relationship / new_partner / engaged / married |  |  |  |
| PRO_691 | Contract Year: The Middle Years | age 30-33 | once | contract_year |  |  |  |
| PRO_692 | Doubts at Thirty | age 30-33 | once | slump_now 1+ |  |  |  |
| PRO_693 | The Thirty-Something Streak | age 30-33 | once | fg_streak 8+ |  |  |  |
| PRO_694 | The Kicker They Drafted | age 30-33 | once |  |  |  |  |
| PRO_695 | Hurt at Thirty | age 30-33 | once | injured_now 1+ |  |  |  |
| PRO_696 | The New Club at Thirty | age 30-33, club season 1 | once | signed_new_club |  |  |  |
| PRO_697 | The Captain's Patch | age 30-33 | once |  |  |  |  |
| PRO_698 | The Holder Retires | age 30-33 | once |  |  |  |  |
| PRO_699 | The Rookie's Holdout | age 30-33 | once |  |  |  |  |
| PRO_700 | The Charity Foundation Gala | age 30-33 | once |  |  | started_foundation |  |
| PRO_701 | Kindergarten Morning | age 30-33 | once | became_parent |  |  |  |
| PRO_702 | The Kid's Team | age 30-33 | once | became_parent |  |  |  |
| PRO_703 | The Anniversary Trip | age 30-33 | once | made_long_distance_work / committed_to_relationship / new_partner / engaged / married |  |  |  |
| PRO_704 | The Marriage Counselor | age 30-33 | once | made_long_distance_work / committed_to_relationship / new_partner / engaged / married |  |  |  |
| PRO_705 | The Old College Friend's Wedding | age 30-33, offseason | once |  |  |  |  |
| PRO_706 | The Old College Rival Retires | age 30-33 | once |  |  |  |  |
| PRO_707 | A Kind Word From {tyler} | age 30-33 | once |  |  |  |  |
| PRO_708 | The Player Rep Meeting | age 30-33 | once |  |  |  |  |
| PRO_709 | The Players' Vote | age 30-33 | once |  |  |  |  |
| PRO_710 | The Rookie Crisis | age 30-33 | once |  |  |  |  |
| PRO_711 | The Second Business | age 30-33 | once | opened_restaurant / dealership_partner / invested_in_friend / franchise_owner / family_business / business_owner |  |  | R3 money values |
| PRO_712 | The Real Estate Pitch | age 30-33 | once |  |  |  | R3 money values |
| PRO_713 | The Investment That Works | age 30-33 | once |  |  |  | R3 money values |
| PRO_714 | The Tax Audit | age 30-33 | once |  |  |  | R3 money values |
| PRO_715 | The Charity Scam | age 30-33 | once |  |  |  |  |
| PRO_716 | The Bad Sponsor | age 30-33 | once |  |  |  |  |
| PRO_717 | The Public Speaking Gig | age 30-33 | once |  |  |  | R3 money values |
| PRO_718 | The Kids' Book | age 30-33 | once |  |  |  | R3 money values |
| PRO_719 | The Commercial Shoot | age 30-33 | once | tier verified |  |  |  |
| PRO_720 | The Late-Night Show | age 30-33 | once | tier verified |  |  |  |
| PRO_721 | The Hometown Field | age 30-33 | once |  |  |  |  |
| PRO_722 | The High School Visit | age 30-33, offseason | once |  |  |  |  |
| PRO_723 | The Kicker You Mentored | age 30-33 | once |  |  |  |  |
| PRO_724 | The New Special Teams Unit | age 30-33 | once |  |  |  |  |
| PRO_725 | The Coordinator's Trick Plays | age 30-33 | once |  |  |  |  |
| PRO_726 | The Veteran Day Off | age 30-33 | once |  |  |  |  |
| PRO_727 | The Body Maintenance Plan | age 30-33 | once |  |  |  |  |
| PRO_728 | The Massage Therapist | age 30-33 | once |  |  |  |  |
| PRO_729 | The Old Injury Flares | age 30-33 | once |  |  |  |  |
| PRO_730 | The Long Practice Week | age 30-33 | once |  |  |  |  |
| PRO_731 | The Teammate's Retirement Speech | age 30-33 | once |  |  |  |  |
| PRO_732 | The Team Historian | age 30-33 | once |  |  |  |  |
| PRO_733 | The Kicking Records Board | age 30-33 | once | pro_seasons 8+ |  |  |  |
| PRO_734 | The Team's Anniversary | age 30-33 | once |  |  |  |  |
| PRO_735 | The Veteran's Union Meeting | age 30-33 | once |  |  |  |  |
| PRO_736 | The Teammate in Rehab | age 30-33 | once |  |  |  |  |
| PRO_737 | The Kicking Camp Partner | age 30-33, offseason | once |  |  |  |  |
| PRO_738 | Baby Number Two | age 30-33 | once | became_parent |  |  |  |
| PRO_739 | The School Play | age 30-33 | once | became_parent |  |  |  |
| PRO_740 | The Parent-Teacher Conference | age 30-33 | once | became_parent |  |  |  |
| PRO_741 | The Family Dog | age 30-33 | once | became_parent |  |  |  |
| PRO_742 | The Partner's New Job | age 30-33 | once | made_long_distance_work / committed_to_relationship / new_partner / engaged / married |  |  |  |
| PRO_743 | The Weekend Away | age 30-33 | once |  |  |  |  |
| PRO_744 | The Veteran Leadership Award | age 30-33 | once |  |  |  |  |
| PRO_745 | The Media Feud | age 30-33 | once |  |  |  |  |
| PRO_746 | The Social Media Break | age 30-33 | once |  |  |  |  |
| PRO_747 | The Charity Ride | age 30-33, offseason | once |  |  |  |  |
| PRO_748 | The Coach Who Believed in You | age 30-33 | once |  |  |  |  |
| PRO_749 | The Teammate's Kid | age 30-33 | once |  |  |  |  |
| PRO_750 | The Prime-Time Interview | age 30-33 | once | tier verified |  |  |  |
| PRO_751 | The Neighbor's Kid | age 30-33 | once |  |  |  |  |
| PRO_752 | Running the Music | age 30-33 | once |  |  |  |  |
| PRO_753 | The Contract Year Pressure at Home | age 30-33 | once | contract_year; made_long_distance_work / committed_to_relationship / new_partner / engaged / married |  |  |  |
| PRO_754 | The Halfway Point | age 30-33 | once | pro_seasons 8+ |  |  |  |
| PRO_755 | The Club's Ring of Honor Nominee | age 30-33 | once | pro_seasons 8+ |  |  |  |
| PRO_756 | The Middle-Aged Rookie | age 30-33 | once |  |  |  |  |
| PRO_757 | The Retirement Seminar | age 30-33 | once |  |  |  |  |
| PRO_758 | The Family Photo | age 30-33 | once | became_parent |  |  |  |
| PRO_759 | The Lost Season | age 30-33 | once |  |  |  |  |
| PRO_760 | The Comeback Practice | age 30-33 | once |  |  |  |  |
| PRO_761 | The Kicker Who Took Your Spot in College | age 30-33 | once |  |  |  |  |
| PRO_762 | The Captain's Dinner | age 30-33 | once |  |  |  |  |
| PRO_763 | The Booster's Favor | age 30-33 | once |  |  |  |  |
| PRO_764 | The Team Doctor's Advice | age 30-33 | once |  |  |  |  |
| PRO_765 | The Kicker in the Stands | age 30-33 | once |  |  |  |  |

- **PRO_022 The National List**: Your name is on the national list for the league's best kicker, and the team's PR staff has eleven requests for you.
- **PRO_023 The Skills Contest**: The league invites you to the long-distance contest at the all-star week. *(kick_challenge (competition) per the gameplay handoff.)*
- **PRO_053 A Coach Out of a Job**: The head coach is fired after a team meeting. {coach}'s office lights are on late.
- **PRO_054 The General Manager's Nephew**: The new general manager is the owner's nephew, and he has opinions about kickers.
- **PRO_055 Loyalty or the Paycheck**: Another club would pay you double. This one gave you your first chance.
- **PRO_063 The Car Dealership**: A dealership wants you as a partner: your face on the billboards, your money in the lot.
- **PRO_070 The Foundation**: Your charity foundation's director is spending more on galas than on kids.
- **PRO_072 Broke at Thirty-Three**: The money's gone faster than the career, and you have a mortgage, a family and maybe three seasons.
- **PRO_073 The Pension Meeting**: The players' union holds a meeting about pensions and retirement plans. Six players show up.
- **PRO_084 The Coach Who Taught You**: Your high school coach is retiring, and the school wants you to speak at the dinner.
- **PRO_088 The Rookie Kicker You Mentor**: The club drafts a kicker and asks you to show the rookie how things work, knowing what that means.
- **PRO_094 The Letter From a Kid**: A letter from a kid in a hospital you visited years ago: he's walking now.
- **PRO_109 The Awards Show**: The league's awards show wants you on the red carpet the night before a practice you can't miss.
- **PRO_131 Thirty**: You turn thirty in camp, and the trainer starts talking about 'maintenance'.
- **PRO_132 The Maintenance Bill**: Holding on to your leg costs more every year: more treatment, more rest, more skill points.
- **PRO_219 Someone New, Later**: Years after it ended, a friend's dinner party seats you next to someone who doesn't care about football at all.
- **PRO_220 The Second Wedding**: A second wedding is smaller, quieter and somehow harder to plan.
- **PRO_221 The Anniversary**: Ten years married, and you're in a hotel in a city you can't remember the name of.
- **PRO_225 {sibling}'s Family**: {sibling} has kids of his own now, and they think you're the most famous person alive.
- **PRO_229 The Radio Show**: A local station offers you a weekly radio show during the season.
- **PRO_235 A Franchise Offer**: A restaurant chain offers you a franchise with your name on it, this time with professionals running it.
- **PRO_238 The Comeback Year**: Last year everyone wrote your obituary. This year you're the first one on the field.
- **PRO_256 Who Am I Without It**: A sleepless night: if you're not the kicker, who are you?
- **PRO_270 The Camp You Teach**: A youth camp asks you to coach for a week. The kids kick terribly and have more fun than you've had in years.
- **PRO_271 The Family Vacation**: A real vacation, no phones, and a family that's not used to having you around for a whole week.
- **PRO_276 Back to Your College**: Your college invites you back for spring practice. The kicking net is in the same place.
- **PRO_279 The Fan Convention**: A fan convention wants you for a signing weekend. The line includes people who've followed you since high school.
- **PRO_280 The Mountain Trip**: Friends plan a climbing trip. Your contract has a clause about 'dangerous activities'.
- **PRO_286 The Off-Season Job Offer**: A company offers you an off-season job in sales. It's real work, and it would be good to know you can do it.
- **PRO_287 Family Reunion, Pro Edition**: The family reunion. Everyone wants a photo, and one uncle wants a loan.
- **PRO_292 The Kicker You Grew Up Watching**: The kicker whose poster hung in your bedroom is at your game, and asks to meet you.
- **PRO_293 The Rule Change**: The league moves the extra-point line again, and the young kickers are thrilled.
- **PRO_297 The Rookie Who Wears Your Number**: A rookie at another club wears your number and says you're the reason.
- **PRO_299 The Coach You Outlasted**: The head coach who drafted you is fired. You're still here.
- **PRO_319 Ten Years**: Ten years in the league. The pension kicks in, and so does the question of how many more.
- **PRO_391 The Room Starts Looking at You**: Teammates have started bringing their problems to your locker.
- **PRO_392 The Coaching Staff Meeting**: A new coach wants to change the preparation routine that got you here.
- **PRO_393 The Family Schedule**: Your kids' games and your schedule are in a war you keep losing.
- **PRO_394 The Retirement Plan**: You sit down and work out how much you'll need after football.
- **PRO_395 The Former Teammate's Retirement**: A longtime teammate retires, and the locker room feels different.
- **PRO_396 The Younger Generation**: A rookie asks how you handle the pressure, and you realize you've never said it out loud.
- **PRO_397 The New Contract Negotiation**: Your agent wants a longer deal, and the club wants a shorter one.
- **PRO_398 The Media Debate**: Analysts debate whether you're still among the best in the league.
- **PRO_399 The Community Commitment**: A local charity wants you as its face, year-round.
- **PRO_400 The Expensive Lifestyle**: Your household's expenses have quietly doubled.
- **PRO_401 The Advisor's Concern**: Your financial advisor questions one of your investments, carefully.
- **PRO_402 The Team Rebuild**: The club starts replacing established players with younger ones.
- **PRO_403 The New Special Teams Coach**: The new coach challenges your preparation, publicly.
- **PRO_404 The Mentor's Retirement**: A coach who shaped your career is stepping away.
- **PRO_405 The Old Rival**: A competitor from years ago reaches out out of nowhere.
- **PRO_406 The Family Business Dispute**: A business with relatives in it is turning into a family fight.
- **PRO_407 The College Invitation**: A university invites you to speak to its football program.
- **PRO_408 The Team's Direction**: You're not sure the franchise is going in the right direction, and someone asks you on the record.
- **PRO_409 The New Home**: Your family has outgrown the house.
- **PRO_410 The Injury Prevention Debate**: You and a trainer disagree about your recovery routine.
- **PRO_411 The Veteran's Committee**: Teammates ask you to represent them in a hard conversation with the coaches.
- **PRO_412 The Charity Board**: A nonprofit invites you to join its board.
- **PRO_413 The Business Partner's Exit**: A partner wants out of a business you built together.
- **PRO_414 Everyone Wants You There**: Your family wants you at more events than you can make.
- **PRO_415 The New Contract Structure**: The club offers a shorter deal with incentives you're not sure you'll hit.
- **PRO_416 The Retirement Rumors**: The media have started asking how much longer you'll play.
- **PRO_417 The Rookie's Confidence**: A young teammate is crumbling under criticism.
- **PRO_418 The Former Coach's Advice**: An old coach tells you to start thinking about your next chapter.
- **PRO_419 A Town's Thank-You**: Your town wants to honor your career, and you're still playing it.
- **PRO_420 The Guest Analyst**: A network offers you a guest analyst spot during your off week.
- **PRO_421 The Family Financial Decision**: You and {love_interest} disagree about a major purchase.
- **PRO_422 The Teammate's Contract**: A teammate asks you how to handle his negotiation.
- **PRO_423 The Offseason Commitment**: Your family wants you home; your training plan doesn't agree.
- **PRO_424 The Hall of Fame Conversation**: A broadcaster asks whether you ever think about your legacy.
- **PRO_425 The Young Kicker's Arrival**: A rookie asks to learn your routine, step by step.
- **PRO_426 The Business Reputation**: A public complaint threatens your business's reputation.
- **PRO_427 The Team's Community Day**: You're asked to organize the club's charity day.
- **PRO_428 The Family Milestone**: A major family occasion falls on a game weekend.
- **PRO_429 The Old Teammate's Request**: A former teammate asks you to back his new venture.
- **PRO_430 The Next Chapter Conversation**: {love_interest} wants to know what you picture for life after football.
- **PRO_691 Contract Year: The Middle Years**: At thirty, a contract year means proving you're not slowing down.
- **PRO_692 Doubts at Thirty**: A slump at thirty, and the questions are about your age, not your form.
- **PRO_693 The Thirty-Something Streak**: A month without a miss, and the stories say you're better than ever.
- **PRO_694 The Kicker They Drafted**: The club drafts a kicker in the middle rounds, and he's watching your every kick.
- **PRO_695 Hurt at Thirty**: An injury at thirty, and the recovery takes longer than it used to.
- **PRO_696 The New Club at Thirty**: A new club, and the young players already know your name.
- **PRO_697 The Captain's Patch**: You wear the captain's patch for the first time.
- **PRO_698 The Holder Retires**: Your longtime holder retires, and the new one is half your age.
- **PRO_699 The Rookie's Holdout**: A rookie holds out, and the veterans want you to talk to him.
- **PRO_700 The Charity Foundation Gala**: Your foundation holds its first gala.
- **PRO_701 Kindergarten Morning**: Your kid's first day of school is a practice day.
- **PRO_702 The Kid's Team**: Your kid's youth team needs a coach, and everyone looks at you.
- **PRO_703 The Anniversary Trip**: You and {love_interest} plan a trip for your anniversary, and the club schedules a minicamp.
- **PRO_704 The Marriage Counselor**: You and {love_interest} decide to see a counselor, before anything's wrong.
- **PRO_705 The Old College Friend's Wedding**: A college friend's wedding brings back the whole old crowd.
- **PRO_706 The Old College Rival Retires**: A kicker you've competed with since college retires.
- **PRO_707 A Kind Word From {tyler}**: {tyler} sends a message after a rough week, and it's kinder than you expected.
- **PRO_708 The Player Rep Meeting**: The players' union holds a meeting about health care for retired players.
- **PRO_709 The Players' Vote**: The team votes on a players-only issue, and they want you to speak first.
- **PRO_710 The Rookie Crisis**: A rookie in crisis calls you at 2 a.m.
- **PRO_711 The Second Business**: You consider a second business, while the first is still finding its feet.
- **PRO_712 The Real Estate Pitch**: A real estate agent pitches you on rental properties.
- **PRO_713 The Investment That Works**: An investment you made years ago starts paying off.
- **PRO_714 The Tax Audit**: You're audited, and every receipt from the last three years matters.
- **PRO_715 The Charity Scam**: A charity using your name turns out to be a scam.
- **PRO_716 The Bad Sponsor**: A sponsor is in the news for the wrong reasons, and your face is on its ads.
- **PRO_717 The Public Speaking Gig**: A company wants you to give a motivational talk to its employees.
- **PRO_718 The Kids' Book**: A publisher wants you to write a kids' book about kicking.
- **PRO_719 The Commercial Shoot**: A national commercial shoot, and the director wants you to act.
- **PRO_720 The Late-Night Show**: A late-night show wants you as a guest.
- **PRO_721 The Hometown Field**: Your hometown names a field after you.
- **PRO_722 The High School Visit**: You visit your old high school, and the kicking net is still behind the bleachers.
- **PRO_723 The Kicker You Mentored**: A kicker you mentored signs with a rival club.
- **PRO_724 The New Special Teams Unit**: Half your special teams unit is new this season.
- **PRO_725 The Coordinator's Trick Plays**: The coordinator wants more fakes and more onside kicks, and he wants you to run them.
- **PRO_726 The Veteran Day Off**: The club gives veterans a day off each week, and you're now one of them.
- **PRO_727 The Body Maintenance Plan**: A trainer builds you a maintenance plan for the next five years.
- **PRO_728 The Massage Therapist**: The team's massage therapist knows your body better than you do.
- **PRO_729 The Old Injury Flares**: An old injury flares up during a road trip.
- **PRO_730 The Long Practice Week**: A long week of practice in the heat, and your legs feel every year.
- **PRO_731 The Teammate's Retirement Speech**: A teammate's retirement speech mentions you by name.
- **PRO_732 The Team Historian**: The club's historian interviews you for the team's archive.
- **PRO_733 The Kicking Records Board**: Your name goes up on the club's kicking records board.
- **PRO_734 The Team's Anniversary**: The club celebrates an anniversary, and you're one of the faces on the banner.
- **PRO_735 The Veteran's Union Meeting**: Veterans meet about the next labor agreement, and it's tense.
- **PRO_736 The Teammate in Rehab**: A teammate goes into rehab for an injury that may end his career.
- **PRO_737 The Kicking Camp Partner**: A college coach asks you to co-host a kicking camp.
- **PRO_738 Baby Number Two**: A second child, and the house feels much smaller.
- **PRO_739 The School Play**: Your kid's school play is the night before a road game.
- **PRO_740 The Parent-Teacher Conference**: You go to your first parent-teacher conference and get recognized by the teacher.
- **PRO_741 The Family Dog**: The family dog is getting old, and the kids are asking questions.
- **PRO_742 The Partner's New Job**: {love_interest} gets a big job offer of their own.
- **PRO_743 The Weekend Away**: A rare weekend away from the city, and your phone won't stop.
- **PRO_744 The Veteran Leadership Award**: The club names you its veteran leadership honoree.
- **PRO_745 The Media Feud**: A columnist has a feud with you, and every column is about you.
- **PRO_746 The Social Media Break**: You take a month off social media, and it feels strange.
- **PRO_747 The Charity Ride**: You ride in a charity bike ride across the state with teammates.
- **PRO_748 The Coach Who Believed in You**: The coach who gave you your first chance is in the hospital.
- **PRO_749 The Teammate's Kid**: A teammate's kid wants to kick, and asks you for lessons.
- **PRO_750 The Prime-Time Interview**: A national network wants an in-depth interview about your career.
- **PRO_751 The Neighbor's Kid**: The neighbor's kid practices kicking in the street every day.
- **PRO_752 Running the Music**: You've been the locker room DJ for years, and a rookie wants the job.
- **PRO_753 The Contract Year Pressure at Home**: Contract year again, and the conversations at home are getting shorter.
- **PRO_754 The Halfway Point**: A reporter asks if you think you're halfway through your career.
- **PRO_755 The Club's Ring of Honor Nominee**: Fans nominate you for the club's ring of honor, while you're still playing.
- **PRO_756 The Middle-Aged Rookie**: A thirty-year-old rookie kicker joins the club, and everyone wants you two to talk.
- **PRO_757 The Retirement Seminar**: The union holds a retirement seminar, and you sit in the back row.
- **PRO_758 The Family Photo**: The family photo for the team's holiday card, and nobody is smiling.
- **PRO_759 The Lost Season**: A season where nothing goes right, for the team or for you.
- **PRO_760 The Comeback Practice**: After a rough week, you have the best practice of your career.
- **PRO_761 The Kicker Who Took Your Spot in College**: The kicker who beat you for a job in college is out of football and asks for help.
- **PRO_762 The Captain's Dinner**: You host the captains for dinner, and it turns into a three-hour argument about the season.
- **PRO_763 The Booster's Favor**: A wealthy booster asks you for a favor that isn't quite against the rules.
- **PRO_764 The Team Doctor's Advice**: The team doctor suggests you start planning your body's next twenty years, not just this season.
- **PRO_765 The Kicker in the Stands**: A retired kicker you admired is in the stands, watching you warm up.

## Era 4: Aging Veteran (34-37) (150)

| ID | Title | Window | Kind | Opens on | Sets | Callbacks (locked choices) | Waits on |
|---|---|---|---|---|---|---|---|
| PRO_038 | Contract Year: One More | age 35-37 | variant | contract_year |  |  |  |
| PRO_081 | {parent}'s Last Season in the Stands | age 34-37 | once |  |  |  |  |
| PRO_087 | {tyler}'s Second Act | age 34-37 | once |  |  |  |  |
| PRO_089 | The Mentee Takes Your Job | age 34-37 | once | mentored_rookie_kicker |  |  |  |
| PRO_097 | The Reunion | age 34-37, offseason | once |  |  |  |  |
| PRO_133 | The Younger Kicker in Camp | age 35-37, weeks 1-3 | variant |  |  |  |  |
| PRO_134 | The One-Year Deal | age 34-37 | once | contract_year |  |  |  |
| PRO_135 | The Veteran Minimum | age 34-37 | once |  |  |  | R3 money values |
| PRO_136 | The Body Says No | age 34-37 | once |  |  |  |  |
| PRO_137 | The Retirement Talk | age 34-37 | once | made_long_distance_work / committed_to_relationship / new_partner / engaged / married | planning_retirement |  |  |
| PRO_138 | The Farewell Season | age 34-37 | once | planning_retirement |  |  |  |
| PRO_139 | The General Manager's Office | age 34-37 | once | retention under 45 |  |  |  |
| PRO_140 | The Comeback Workout | age 34-37 | once | signed_new_club + released |  |  |  |
| PRO_141 | The Broadcast Booth | age 34-37 | once |  | broadcast_offer |  |  |
| PRO_142 | The Coaching Offer | age 34-37 | once |  | coaching_offer | mentored_rookie_kicker, mentored_backup |  |
| PRO_145 | The Last Contract | age 34-37 | once | re_signed |  |  |  |
| PRO_146 | Your Kid Wants to Kick | age 34-37 | once | became_parent |  |  |  |
| PRO_147 | The Ring of Honor | age 34-37, club season 7+ | once |  |  |  |  |
| PRO_148 | Cleaning Out the Locker | age 34-37 | once | released |  |  |  |
| PRO_149 | What's Next | age 34-37 | once |  |  | finished_degree_track, life_after_football |  |
| PRO_180 | The Veteran Slump | age 35-37 | variant | slump_now 1+ |  | saw_sports_psych, leaned_on_support |  |
| PRO_185 | Still Got It | age 35-37 | variant | fg_streak 8+ |  |  |  |
| PRO_193 | The Body Keeps Score | age 35-37 | variant | injured_now 1+ |  | committed_to_recovery, hid_injury |  |
| PRO_197 | The Veteran Signing | age 35-37 | variant | signed_new_club |  |  |  |
| PRO_212 | The Young Coach | age 34-37 | repeat |  |  |  |  |
| PRO_215 | The Kid Wants to Quit | age 34-37 | once | became_parent |  |  |  |
| PRO_216 | Teenagers | age 34-37 | once | became_parent |  |  |  |
| PRO_218 | A Second Child | age 34-37 | once | became_parent + married |  |  |  |
| PRO_222 | {parent} Moves In | age 34-37 | once |  |  |  |  |
| PRO_223 | {parent} in the Hospital Again | age 34-37 | once |  |  |  |  |
| PRO_224 | The Funeral | age 34-37 | once |  |  |  |  |
| PRO_226 | {best_friend} Is Sick | age 34-37 | once |  |  |  |  |
| PRO_227 | {tyler} Retires | age 34-37 | once |  |  |  |  |
| PRO_228 | The Mentor's Funeral | age 34-37 | once | learned_from_veteran |  |  |  |
| PRO_230 | The Coaching Clinic | age 34-37, offseason | once |  | coached_clinic |  |  |
| PRO_231 | The Broadcast Audition | age 34-37 | once | broadcast_offer |  |  |  |
| PRO_232 | The Coaching Job, Part-Time | age 34-37 | once | coaching_offer / coached_clinic |  |  |  |
| PRO_237 | The Foundation at Ten | age 34-37 | once | started_foundation |  |  |  |
| PRO_239 | The Record Book | age 34-37, club season 5+ | once |  |  |  |  |
| PRO_240 | Hall of Fame Talk | age 34-37 | once | pro_seasons 12+ |  |  |  |
| PRO_241 | Your Number at the High School | age 34-37, offseason | once |  |  | earned_coach_confidence |  |
| PRO_242 | The Documentary | age 34-37 | once | tier verified |  |  |  |
| PRO_243 | The All-Decade Team | age 34-37 | once | pro_seasons 10+ |  |  |  |
| PRO_253 | The Body Decides | age 34-37 | once | injured_now 1+ |  |  |  |
| PRO_259 | The Recovery Clinic | age 34-37 | once |  | pro_banned_substance |  |  |
| PRO_260 | Young Again | age 34-37 | once |  | pro_night_out |  |  |
| PRO_261 | The Business Shortcut | age 34-37 | once |  | pro_business_fraud |  | R3 money values |
| PRO_262 | Betting to Cover It | age 34-37 | once |  | pro_betting_scandal |  | R3 money values; R9 longer suspensions |
| PRO_263 | The Phantom Injury | age 34-37 | once |  | pro_phantom_injury |  |  |
| PRO_264 | Teaching the Wrong Thing | age 34-37 | once |  | pro_bad_mentor |  |  |
| PRO_265 | The Grudge | age 34-37 | once |  | pro_bar_fight |  |  |
| PRO_266 | The Insurance Claim | age 34-37 | once |  | pro_insurance_fraud |  | R3 money values |
| PRO_267 | The Last Big Night | age 34-37 | once | announced_retirement | pro_night_before |  |  |
| PRO_268 | The Veteran Hearing | age 34-37 | once | pro_warning | pro_second_chance |  | R9 longer suspensions |
| PRO_281 | The Body Rebuild | age 34-37, offseason | once |  |  |  |  |
| PRO_289 | The Locker Room Elder | age 34-37 | once |  |  |  |  |
| PRO_290 | Uncle to the Rookies | age 34-37 | once |  |  |  |  |
| PRO_291 | Your Old Holder Coaches Now | any | once | pro_seasons 10+ |  |  |  |
| PRO_294 | The Stadium Closes | any | once | pro_seasons 10+ |  |  |  |
| PRO_295 | The Two-Hundredth Game | any | once | pro_seasons 12+ |  |  |  |
| PRO_296 | The Old Teammates' Reunion | offseason | once | pro_seasons 10+ |  |  |  |
| PRO_298 | A Teammate's Kid Asks for Advice | age 34-37 | once |  |  |  |  |
| PRO_300 | The Analytics Report | age 34-37 | once |  |  |  |  |
| PRO_301 | Losing a Step | age 34-37 | once |  |  |  |  |
| PRO_302 | The Owner's Funeral | any | once | pro_seasons 10+ |  |  |  |
| PRO_303 | A Midnight Call From an Old Teammate | any | once | pro_seasons 10+ |  |  | R3 money values |
| PRO_304 | The Retired Players' Meeting | age 34-37 | once | player_rep |  |  |  |
| PRO_305 | The Old Lineman's Memory | age 34-37 | once |  |  |  |  |
| PRO_306 | The Last of Your Draft Class | any | once | pro_seasons 13+ |  |  |  |
| PRO_307 | The Kid Who Was Born on Draft Day | any | once | pro_seasons 14+ |  |  |  |
| PRO_431 | The Short-Term Contract | age 34-37 | once |  |  |  |  |
| PRO_432 | The Veteran's Discount | age 34-37 | once |  |  |  | R3 money values |
| PRO_433 | The Release Rumors | age 34-37 | once | retention under 50 |  |  |  |
| PRO_434 | The Free Agent Market | age 34-37, club season 1, weeks 1-3 | once | signed_new_club + released |  |  |  |
| PRO_435 | The Backup Role | age 34-37 | once |  |  |  |  |
| PRO_436 | The Old Injury | age 34-37 | once |  |  |  |  |
| PRO_437 | The Retirement Savings Review | age 34-37 | once |  |  |  | R3 money values |
| PRO_438 | The Family's Patience | age 34-37 | once | made_long_distance_work / committed_to_relationship / new_partner / engaged / married |  |  |  |
| PRO_439 | The Empty Nest Approaches | age 34-37 | once | became_parent |  |  |  |
| PRO_440 | The Younger Teammate's Question | age 34-37 | once |  |  |  |  |
| PRO_441 | Another One Hangs It Up | age 34-37 | once |  |  |  |  |
| PRO_442 | One More Big Deal? | age 34-37 | once |  |  |  |  |
| PRO_443 | The Media's Age Debate | age 34-37 | once |  |  |  |  |
| PRO_444 | The Training Load | age 34-37 | once |  |  |  |  |
| PRO_445 | The Business Offer | age 34-37 | once |  | business_owner |  | R3 money values |
| PRO_446 | The Charity Legacy | age 34-37 | once |  |  |  |  |
| PRO_447 | The Franchise Rebuild | age 34-37 | once |  |  |  |  |
| PRO_448 | The New Kicker's Contract | age 34-37 | once |  |  |  |  |
| PRO_449 | The Contract Incentives | age 34-37 | once |  |  |  |  |
| PRO_450 | The Hometown Recognition | age 34-37 | once |  |  |  |  |
| PRO_451 | The Former Coach's Return | age 34-37 | once |  |  |  |  |
| PRO_452 | The Veteran's Perspective | age 34-37 | once |  |  |  |  |
| PRO_453 | The Unexpected Release | age 34-37, club season 1, weeks 1-3 | once | signed_new_club + released |  |  |  |
| PRO_454 | The Record Watch | age 34-37 | once | pro_seasons 10+ |  |  |  |
| PRO_455 | After Football, in the Family Firm | age 34-37 | once |  |  |  | R3 money values |
| PRO_456 | The Old Training Facility | age 34-37 | once |  |  |  |  |
| PRO_457 | The Record Falls | age 34-37 | once |  |  |  |  |
| PRO_458 | The Agent's Advice | age 34-37 | once |  |  |  |  |
| PRO_459 | The Former Teammate's Offer | age 34-37 | once |  |  |  |  |
| PRO_460 | The Final Home Game Question | age 34-37 | once |  |  |  |  |
| PRO_461 | The Retirement Press Conference Rumor | age 34-37 | once |  |  |  |  |
| PRO_462 | The Missed Family Event | age 34-37 | once |  |  |  |  |
| PRO_463 | The Investment Decision | age 34-37 | once |  |  |  | R3 money values |
| PRO_464 | The Career Retrospective | age 34-37 | once |  |  |  |  |
| PRO_766 | The Thirty-Fifth Birthday | age 34-37 | once |  |  |  |  |
| PRO_767 | Training for Longevity | age 34-37 | once |  |  |  |  |
| PRO_768 | The Doctor's Honest Talk | age 34-37 | once |  |  |  |  |
| PRO_769 | The Teammates Half Your Age | age 34-37 | once |  |  |  |  |
| PRO_770 | The New Coach Who Doesn't Know You | age 34-37 | once |  |  |  |  |
| PRO_771 | Three Possible Futures | age 34-37 | once |  |  |  | R3 money values |
| PRO_772 | The Teen at Home | age 34-37 | once | became_parent |  |  |  |
| PRO_773 | The College Visits | age 34-37, offseason | once | became_parent |  |  |  |
| PRO_774 | The Last Contract Year | age 34-37 | once | contract_year |  |  |  |
| PRO_775 | The Long Goodbye of a Teammate | age 34-37 | once |  |  |  |  |
| PRO_776 | The Specialists' Reunion | age 34-37, offseason | once |  |  |  |  |
| PRO_777 | The Kicking Tape Library | age 34-37 | once |  |  |  |  |
| PRO_778 | The Second Wind | age 34-37 | once |  |  |  |  |
| PRO_779 | The Missed Kick Story | age 34-37 | once |  |  |  |  |
| PRO_780 | The Age Joke | age 34-37 | once |  |  |  |  |
| PRO_781 | The Cortisone Talk | age 34-37 | once |  |  |  |  |
| PRO_782 | The Last Big Endorsement | age 34-37 | once | tier verified |  |  | R3 money values |
| PRO_783 | The Long Snapper's Son | age 34-37 | once |  |  |  |  |
| PRO_784 | The Veteran Minimum, Again | age 34-37 | once |  |  |  | R3 money values |
| PRO_785 | The Hometown Hall | age 34-37, offseason | once |  |  |  |  |
| PRO_786 | The Old Friend's Funeral | age 34-37 | once |  |  |  |  |
| PRO_787 | The Teammate's Concussion Story | age 34-37 | once |  |  |  |  |
| PRO_788 | The Partner's Patience | age 34-37 | once | made_long_distance_work / committed_to_relationship / new_partner / engaged / married |  |  |  |
| PRO_789 | The Family Retreat | age 34-37, offseason | once | became_parent |  |  |  |
| PRO_790 | The Coaching Clinic Offer | age 34-37, offseason | once |  |  |  |  |
| PRO_791 | The Broadcasting Tryout | age 34-37 | once |  |  |  |  |
| PRO_792 | The Old Rival's Comeback | age 34-37 | once |  |  |  |  |
| PRO_793 | Signed for Your Experience | age 34-37, club season 1, weeks 1-3 | once | signed_new_club + released |  |  |  |
| PRO_794 | The Locker Room Story Time | age 34-37 | once |  |  |  |  |
| PRO_795 | The Last Charity Game | age 34-37 | once |  |  |  |  |
| PRO_796 | The Final Season Tour Idea | age 34-37 | once |  |  |  |  |
| PRO_797 | The Rookie Who Calls You 'Sir' | age 34-37 | once |  |  |  |  |
| PRO_798 | The Lost Step | age 34-37 | once |  |  |  |  |
| PRO_799 | The Family Business Offer | age 34-37 | once |  |  |  | R3 money values |
| PRO_800 | The Fan Who Has Seen Every Game | age 34-37 | once |  |  |  |  |
| PRO_801 | The Body Scan | age 34-37 | once |  |  |  |  |
| PRO_802 | The Last Contract Negotiation Tactics | age 34-37 | once | contract_year |  |  |  |
| PRO_803 | The Teammate's Farewell Speech | age 34-37 | once |  |  |  |  |
| PRO_804 | The Team Chaplain | age 34-37 | once |  |  |  |  |
| PRO_805 | The Old Locker Room Rules | age 34-37 | once |  |  |  |  |
| PRO_806 | The Media Room Farewell | age 34-37 | once |  |  |  |  |
| PRO_807 | The Trainer's Retirement | age 34-37 | once |  |  |  |  |
| PRO_808 | New Gear, Old Habits | age 34-37 | once |  |  |  |  |
| PRO_809 | The Young Kicker's Thank-You | age 34-37 | once |  |  |  |  |
| PRO_810 | The Ring of Honor Nomination | age 34-37 | once | pro_seasons 10+ |  |  |  |
| PRO_811 | The Last Opening Day | age 34-37 | once |  |  |  |  |

- **PRO_038 Contract Year: One More**: At your age, the next contract is one year at a time, and everyone in the building knows it.
- **PRO_081 {parent}'s Last Season in the Stands**: {parent} says this is the last season he'll make the drive to watch you.
- **PRO_087 {tyler}'s Second Act**: {tyler} is in the broadcast booth now, and he's calling your games.
- **PRO_089 The Mentee Takes Your Job**: The kicker you taught is better than you now, and {coach} wants to tell you before the depth chart comes out.
- **PRO_097 The Reunion**: Your high school reunion is the weekend after the season, and everyone wants to know what the league is like.
- **PRO_133 The Younger Kicker in Camp**: The club drafts a kicker in the fourth round, and he's sitting in your seat in the meeting room.
- **PRO_134 The One-Year Deal**: The offer is one year, the minimum, and a phone call that says take it or leave it.
- **PRO_135 The Veteran Minimum**: You're making a third of what you made five years ago, and the rookie next to you has your old car.
- **PRO_136 The Body Says No**: Your hip takes an hour to warm up now, and Monday mornings take two.
- **PRO_137 The Retirement Talk**: Your partner asks, gently, how many more seasons. *(Partner version; a single player gets the same question in PRO_149 What's Next.)*
- **PRO_138 The Farewell Season**: Do you tell the world this is your last season, or let it end quietly? *(The retirement itself is the player's choice on the contract screen.)*
- **PRO_139 The General Manager's Office**: The general manager says they're going in a different direction at kicker next season. *(Foreshadows the engine's release; retention lags a season.)*
- **PRO_140 The Comeback Workout**: Released last spring, signed this summer: everyone in camp thinks you're finished.
- **PRO_141 The Broadcast Booth**: A network offers you a job in the booth when you're done.
- **PRO_142 The Coaching Offer**: A college asks if you'd coach their kickers when you retire.
- **PRO_145 The Last Contract**: This contract is probably the last one, and your agent says so out loud.
- **PRO_146 Your Kid Wants to Kick**: Your kid wants to kick in middle school, and asks you to teach them.
- **PRO_147 The Ring of Honor**: The club wants to put your name in the stadium's ring of honor after you retire.
- **PRO_148 Cleaning Out the Locker**: You're cleaning out a locker after a release for the first time, and nobody walks by. *(At the new club, about the old one.)*
- **PRO_149 What's Next**: Your agent, your partner and your accountant all ask the same question in the same week.
- **PRO_180 The Veteran Slump**: At your age a slump doesn't look like a slump. It looks like the end, and talk radio says so.
- **PRO_185 Still Got It**: A run of makes at your age, and every story calls it a 'renaissance'. You'd call it work.
- **PRO_193 The Body Keeps Score**: The trainers say this one will heal. They also say the next one might not.
- **PRO_197 The Veteran Signing**: They signed you for your experience. The young players want to know what that means.
- **PRO_212 The Young Coach**: The new special teams coach is younger than you, and wants to change your warmup. *(Repeatable (15-week cooldown). Locked choices open with experience: min pro_seasons 3 / 6 / 10, age, earlier flags.)*
- **PRO_215 The Kid Wants to Quit**: Your kid wants to quit their own team, and asks you not to be mad.
- **PRO_216 Teenagers**: Your teenager says they're tired of being 'the kicker's kid' at school.
- **PRO_218 A Second Child**: Another baby is coming, and the house already feels small.
- **PRO_222 {parent} Moves In**: {parent} can't live alone anymore, and your house has a spare room.
- **PRO_223 {parent} in the Hospital Again**: Another call from home. This time the doctor uses the word 'months'.
- **PRO_224 The Funeral**: {parent}'s funeral is on a Thursday. The club says take all the time you need, and means a week.
- **PRO_226 {best_friend} Is Sick**: {best_friend} calls with news that makes the season feel very small.
- **PRO_227 {tyler} Retires**: {tyler} retires and asks you to speak at the press conference.
- **PRO_228 The Mentor's Funeral**: The veteran who taught you the most in your rookie year has died.
- **PRO_230 The Coaching Clinic**: You run your first coaching clinic for high school kickers and find out you might be good at this.
- **PRO_231 The Broadcast Audition**: The network wants an audition tape. Your agent wants you to keep kicking.
- **PRO_232 The Coaching Job, Part-Time**: A college asks you to coach its kickers in the offseason, while you're still playing.
- **PRO_237 The Foundation at Ten**: Your foundation turns ten, and the kids from its first year are in college.
- **PRO_239 The Record Book**: You're close to a club record nobody thought a kicker would hold.
- **PRO_240 Hall of Fame Talk**: A columnist writes that you belong in the Hall of Fame. Another writes that kickers don't.
- **PRO_241 Your Number at the High School**: Your high school wants to retire your number.
- **PRO_242 The Documentary**: A filmmaker wants to follow you for a season.
- **PRO_243 The All-Decade Team**: The league names its all-decade team, and the vote for kicker is close.
- **PRO_253 The Body Decides**: A doctor shows you an X-ray and says the choice may not be yours much longer.
- **PRO_259 The Recovery Clinic**: A clinic promises to make your thirty-eight-year-old leg feel twenty-eight. Its menu includes a banned substance. *(Clean no with its own payoff in every scene; never shown using anything. The strike feeds the team-discipline steps.)*
- **PRO_260 Young Again**: The young players go out every night after games, and they keep inviting you, like you're one of them. *(Clean no with its own payoff in every scene; never shown using anything. The strike feeds the team-discipline steps.)*
- **PRO_261 The Business Shortcut**: Your business is losing money, and your partner has a way to make the books look better. *(Clean no with its own payoff in every scene; never shown using anything. The strike feeds the team-discipline steps.)*
- **PRO_262 Betting to Cover It**: You're short on money, and an old acquaintance says one good week of bets would fix everything. *(Clean no with its own payoff in every scene; never shown using anything. The strike feeds the team-discipline steps.)*
- **PRO_263 The Phantom Injury**: A teammate says a phantom injury would keep you on the roster and paid for the rest of the year. *(Clean no with its own payoff in every scene; never shown using anything. The strike feeds the team-discipline steps.)*
- **PRO_264 Teaching the Wrong Thing**: A rookie asks how you've lasted this long, and the honest answer includes a few things you shouldn't teach. *(Clean no with its own payoff in every scene; never shown using anything. The strike feeds the team-discipline steps.)*
- **PRO_265 The Grudge**: The general manager who released you two years ago is at the same restaurant, and he's laughing. *(Clean no with its own payoff in every scene; never shown using anything. The strike feeds the team-discipline steps.)*
- **PRO_266 The Insurance Claim**: Your agent suggests an insurance claim on an injury that's mostly healed. *(Clean no with its own payoff in every scene; never shown using anything. The strike feeds the team-discipline steps.)*
- **PRO_267 The Last Big Night**: Your farewell season, a city that loves you, and a night out that could end it badly. *(Clean no with its own payoff in every scene; never shown using anything. The strike feeds the team-discipline steps.)*
- **PRO_268 The Veteran Hearing**: Another hearing at your age. The league says experience should have known better. *(Clean no with its own payoff in every scene; never shown using anything. The strike feeds the team-discipline steps.)*
- **PRO_281 The Body Rebuild**: A new trainer wants to rebuild how you move, from the ground up, at an age when most kickers stop changing.
- **PRO_289 The Locker Room Elder**: You're the oldest player in the locker room, and the young ones bring their problems to you.
- **PRO_290 Uncle to the Rookies**: A rookie calls you 'unc' at practice. It sticks.
- **PRO_291 Your Old Holder Coaches Now**: Your first pro holder is a coach now, and is coaching against you on Sunday.
- **PRO_294 The Stadium Closes**: The club's old stadium is being torn down after this season. You've played more games there than anyone left on the roster.
- **PRO_295 The Two-Hundredth Game**: Your two-hundredth game as a pro. The club makes a video, and you can't watch it.
- **PRO_296 The Old Teammates' Reunion**: Your rookie class has a reunion. Half of them have bad knees and good stories.
- **PRO_298 A Teammate's Kid Asks for Advice**: A teammate's teenage kid kicks for a high school team and wants your advice.
- **PRO_300 The Analytics Report**: The club's analysts present a chart: your leg is getting older faster than you are.
- **PRO_301 Losing a Step**: Your longest kick in practice is five yards shorter than last year. The coaches haven't said it, but they've noticed.
- **PRO_302 The Owner's Funeral**: The owner who signed you dies, and the family asks you to speak.
- **PRO_303 A Midnight Call From an Old Teammate**: A teammate from your rookie year is broke and calls you at midnight.
- **PRO_304 The Retired Players' Meeting**: Retired players are organizing for better health care, and they want a current player at the meeting.
- **PRO_305 The Old Lineman's Memory**: A lineman you played with for years doesn't remember your name at a reunion.
- **PRO_306 The Last of Your Draft Class**: You're the last player from your draft class still in the league.
- **PRO_307 The Kid Who Was Born on Draft Day**: A rookie mentions he was born the week you were drafted.
- **PRO_431 The Short-Term Contract**: Your agent can't find a club willing to offer more than a year or two.
- **PRO_432 The Veteran's Discount**: The club asks you to take less to stay.
- **PRO_433 The Release Rumors**: The papers say you could be cut before the season starts.
- **PRO_434 The Free Agent Market**: The first week at a new club, after a spring of far fewer calls than you expected.
- **PRO_435 The Backup Role**: A club offers you a job behind a younger kicker.
- **PRO_436 The Old Injury**: A previous injury has started affecting your preparation.
- **PRO_437 The Retirement Savings Review**: You go over your finances again with a different question in mind.
- **PRO_438 The Family's Patience**: {love_interest} is tired of not knowing whether there'll be another season.
- **PRO_439 The Empty Nest Approaches**: Your kids are getting ready to leave home.
- **PRO_440 The Younger Teammate's Question**: A rookie asks whether age really matters in this league.
- **PRO_441 Another One Hangs It Up**: Another veteran from your era retires.
- **PRO_442 One More Big Deal?**: You wonder whether you'll ever get another real contract.
- **PRO_443 The Media's Age Debate**: Analysts question whether older kickers can be trusted.
- **PRO_444 The Training Load**: You have to choose between training hard and recovering.
- **PRO_445 The Business Offer**: A former teammate offers you a role in his business.
- **PRO_446 The Charity Legacy**: You consider making your community work permanent.
- **PRO_447 The Franchise Rebuild**: The club starts a rebuild, and veterans are expensive.
- **PRO_448 The New Kicker's Contract**: Your likely replacement signs a big deal.
- **PRO_449 The Contract Incentives**: Your new deal has strict performance requirements.
- **PRO_450 The Hometown Recognition**: Your hometown wants to honor your career.
- **PRO_451 The Former Coach's Return**: A coach from early in your career is back in the league.
- **PRO_452 The Veteran's Perspective**: Younger players ask what the league was like when you came in.
- **PRO_453 The Unexpected Release**: The first week at a new club, after the old one let you go in the middle of a season.
- **PRO_454 The Record Watch**: You're close to a major career milestone.
- **PRO_455 After Football, in the Family Firm**: Your family wants you in a business after football.
- **PRO_456 The Old Training Facility**: You visit the facility where your pro career started.
- **PRO_457 The Record Falls**: A young kicker breaks one of your records.
- **PRO_458 The Agent's Advice**: Your agent says it's time to prepare for retirement.
- **PRO_459 The Former Teammate's Offer**: A retired teammate offers you a job at his company.
- **PRO_460 The Final Home Game Question**: Your family asks whether this could be your last season.
- **PRO_461 The Retirement Press Conference Rumor**: Reporters keep asking whether you've decided.
- **PRO_462 The Missed Family Event**: You miss an important family occasion because of football.
- **PRO_463 The Investment Decision**: You consider investing heavily in life after football.
- **PRO_464 The Career Retrospective**: A journalist wants to tell the story of your career, start to finish.
- **PRO_766 The Thirty-Fifth Birthday**: You turn thirty-five in camp, and the young players bake you a cake shaped like a walker.
- **PRO_767 Training for Longevity**: You rebuild your training plan around recovery, not volume.
- **PRO_768 The Doctor's Honest Talk**: A team doctor tells you, plainly, how much longer your hip has.
- **PRO_769 The Teammates Half Your Age**: You realize half your teammates were in middle school when you were drafted.
- **PRO_770 The New Coach Who Doesn't Know You**: A new head coach arrives and has never seen you kick.
- **PRO_771 Three Possible Futures**: A retirement planner shows you three futures, and only one has football in it.
- **PRO_772 The Teen at Home**: Your teenager stops coming to games.
- **PRO_773 The College Visits**: You drive your kid to college visits during the offseason.
- **PRO_774 The Last Contract Year**: What may be your last contract year.
- **PRO_775 The Long Goodbye of a Teammate**: A teammate's career is ending slowly, and he won't admit it.
- **PRO_776 The Specialists' Reunion**: The specialists you came up with meet for a reunion dinner.
- **PRO_777 The Kicking Tape Library**: You go through old tape of yourself, and you look like a different person.
- **PRO_778 The Second Wind**: A month where everything feels easy again.
- **PRO_779 The Missed Kick Story**: A reporter writes a long story about the kicks you've missed, not the ones you made.
- **PRO_780 The Age Joke**: Every broadcast now has a joke about your age.
- **PRO_781 The Cortisone Talk**: A doctor offers a shot to get you through the season, and you have to decide.
- **PRO_782 The Last Big Endorsement**: A sponsor offers what may be your last big deal.
- **PRO_783 The Long Snapper's Son**: The son of the long snapper you started with is now a long snapper himself.
- **PRO_784 The Veteran Minimum, Again**: Another season at the veteran minimum.
- **PRO_785 The Hometown Hall**: Your hometown sports hall of fame inducts you.
- **PRO_786 The Old Friend's Funeral**: A friend from your rookie class dies young.
- **PRO_787 The Teammate's Concussion Story**: A retired teammate goes public about his concussions.
- **PRO_788 The Partner's Patience**: {love_interest} asks for one season with no surprises.
- **PRO_789 The Family Retreat**: The whole family takes a week off together, the first in years.
- **PRO_790 The Coaching Clinic Offer**: A college wants you to run its kicking clinic every summer.
- **PRO_791 The Broadcasting Tryout**: A network asks you to call one game during your off week.
- **PRO_792 The Old Rival's Comeback**: {tyler} attempts a comeback, and asks you for advice.
- **PRO_793 Signed for Your Experience**: A new club signs you for experience, and the room is skeptical.
- **PRO_794 The Locker Room Story Time**: Young players gather around your locker for stories after practice.
- **PRO_795 The Last Charity Game**: You play in the charity game you've hosted for ten years, maybe for the last time.
- **PRO_796 The Final Season Tour Idea**: Your agent pitches a farewell season tour you haven't agreed to.
- **PRO_797 The Rookie Who Calls You 'Sir'**: A rookie calls you 'sir' and means it.
- **PRO_798 The Lost Step**: Your range is shrinking, and the coaches have adjusted the kicking chart without telling you.
- **PRO_799 The Family Business Offer**: {sibling} wants you to join his business when you retire.
- **PRO_800 The Fan Who Has Seen Every Game**: A fan has been to every one of your home games, and wants a picture for the last one.
- **PRO_801 The Body Scan**: A full-body scan shows every injury you've ever had.
- **PRO_802 The Last Contract Negotiation Tactics**: Your agent wants to play hardball one last time.
- **PRO_803 The Teammate's Farewell Speech**: A retiring teammate's speech leaves the room silent.
- **PRO_804 The Team Chaplain**: The team chaplain asks how you're really doing.
- **PRO_805 The Old Locker Room Rules**: The young players have changed the locker room rules, and they ask your opinion.
- **PRO_806 The Media Room Farewell**: A beat reporter who's covered you since your rookie year is retiring.
- **PRO_807 The Trainer's Retirement**: The trainer who has taped your ankle for years is retiring.
- **PRO_808 New Gear, Old Habits**: New cleats, new balls, new tech, and your old routine doesn't fit.
- **PRO_809 The Young Kicker's Thank-You**: A young kicker at another club thanks you publicly for advice you forgot you gave.
- **PRO_810 The Ring of Honor Nomination**: You're nominated for the club's ring of honor.
- **PRO_811 The Last Opening Day**: What might be your last opening day, and you notice everything.

## Era 5: Grizzled Veteran (38-41) (80)

| ID | Title | Window | Kind | Opens on | Sets | Callbacks (locked choices) | Waits on |
|---|---|---|---|---|---|---|---|
| PRO_143 | Forty | age 40 | once |  |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_150 | The Note in the Locker | age 38-41 | once |  |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_176 | Contract Year: The Phone Call Every Spring | age 38-40 | variant | contract_year |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_181 | The Slump Nobody Waits Out | age 38-40 | variant | slump_now 1+ |  | saw_sports_psych, leaned_on_support | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_186 | The Oldest Streak | age 38-40 | variant | fg_streak 8+ |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_189 | The Kid in Your Seat | age 38-40, weeks 1-3 | variant |  |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_194 | Six Weeks at Your Age | age 38-40 | variant | injured_now 1+ |  | committed_to_recovery, hid_injury | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_198 | The Last Stop? | age 38-40 | variant | signed_new_club |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_217 | Graduation Day | age 38-41 | once | became_parent |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_308 | Kicking in Your Forties | age 40 | once |  |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_465 | The Oldest Player in the League | age 38-41 | once |  |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_466 | The One-Year Contract | age 38-41 | once | contract_year |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_467 | The Recovery Challenge | age 38-41 | once |  |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_468 | The Record Chase | age 38-41 | once | pro_seasons 14+ |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_469 | The Former Teammate's Induction | age 38-41 | once |  |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_470 | The Friend's Retirement | age 38-41 | once |  |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_471 | The Agent's Final Pitch | age 38-41 | once |  |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_472 | The Team's Salary Decision | age 38-41 | once | retention under 50 |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_473 | The Younger Kicker's Challenge | age 38-41 | once |  |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_474 | The Old Stadium | age 38-41 | once |  |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_475 | The Jersey Recognition | age 38-41 | once |  |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_476 | The Retirement Interview | age 38-41 | once |  |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_477 | The Specialists Job | age 38-41 | once |  |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_478 | The Broadcasting Contract | age 38-41 | once |  |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_479 | The Family Reunion | age 38-41 | once |  |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_480 | The Empty House | age 38-41 | once | became_parent |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_481 | The Financial Freedom Question | age 38-41 | once |  |  |  | R3 money values; R1 no age cap (ages 39-41; 38 plays now) |
| PRO_482 | Partners in Something New | age 38-41 | once |  | business_owner |  | R3 money values; R1 no age cap (ages 39-41; 38 plays now) |
| PRO_483 | Opening an Academy | age 38-41 | once |  | business_owner |  | R3 money values; R1 no age cap (ages 39-41; 38 plays now) |
| PRO_484 | The Old Rival's Message | age 38-41 | once |  |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_485 | The Hall of Fame Discussion | age 38-41 | once | pro_seasons 14+ |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_486 | The Final Jersey | age 38-41 | once |  |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_487 | The New Generation of Kickers | age 38-41 | once |  |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_488 | One Last Negotiation | age 38-41 | once | contract_year |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_489 | The Family's Concern | age 38-41 | once |  |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_490 | The Longest Career Record | age 38-41 | once | pro_seasons 16+ |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_491 | The Old Training Routine | age 38-41 | once |  |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_492 | A Program for Former Players | age 38-41 | once |  |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_493 | The Former Coach's Legacy | age 38-41 | once |  |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_494 | The Franchise's Tribute | age 38-41 | once |  |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_495 | The Young Coach's Challenge | age 38-41 | once |  |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_496 | The Free Agency Wait | age 38-41, club season 1, weeks 1-3 | once | signed_new_club + released |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_497 | One Last Offseason | age 38-41, offseason | once |  |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_498 | The Retirement Financial Plan | age 38-41 | once |  |  |  | R3 money values; R1 no age cap (ages 39-41; 38 plays now) |
| PRO_499 | The Hometown Statue Proposal | age 38-41 | once |  |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_500 | The Team Ambassador Role | age 38-41 | once |  |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_501 | The Last Locker Room Speech | age 38-41 | once |  |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_502 | The Retirement Announcement Question | age 38-41 | once |  |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_503 | The Former Rival's Retirement | age 38-41 | once |  |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_504 | The Next Chapter Contract | age 38-41 | once |  |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_505 | The Legacy Foundation | age 38-41 | once |  |  |  | R3 money values; R1 no age cap (ages 39-41; 38 plays now) |
| PRO_506 | The Final Decision | age 38-41, offseason | once |  |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_812 | The Thirty-Eighth Camp | age 38-41 | once |  |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_813 | The Oldest Locker | age 38-41 | once |  |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_814 | The Doctors' Second Opinion | age 38-41 | once |  |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_815 | The Medical Clearance | age 38-41 | once |  |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_816 | The Recovery Pool | age 38-41 | once |  |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_817 | The Grandparent Question | age 38-41 | once |  |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_818 | The Grandchild | age 38-41 | once | became_parent |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_819 | The Kid in College | age 38-41 | once | became_parent |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_820 | The Family's Last Road Trip | age 38-41 | once |  |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_821 | Another Make-or-Break Year | age 38-41 | once | contract_year |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_822 | The League's Oldest Kickers | age 38-41 | once | pro_seasons 15+ |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_823 | The Rule You Remember | age 38-41 | once |  |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_824 | The Former Teammate as Head Coach | age 38-41 | once |  |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_825 | The Kicker You Watched Retire | age 38-41 | once |  |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_826 | The Night Practice | age 38-41 | once |  |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_827 | The New Recovery Tech | age 38-41 | once |  |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_828 | The Gala in Your Honor | age 38-41 | once |  |  | started_foundation | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_829 | The Retirement Present | age 38-41 | once |  |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_830 | The Last Contract Signing | age 38-41 | once |  |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_831 | The Long Snapper's Retirement | age 38-41 | once |  |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_832 | The Rival's Kid | age 38-41 | once |  |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_833 | The Old College Coach's Funeral | age 38-41 | once |  |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_834 | The Weight You Can't Lose | age 38-41 | once |  |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_835 | The Sleep You Need | age 38-41 | once |  |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_836 | The Young Coach's Respect | age 38-41 | once |  |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_837 | The Media's Last Questions | age 38-41 | once |  |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_838 | The Fan's Memory | age 38-41 | once |  |  |  | R1 no age cap (ages 39-41; 38 plays now) |
| PRO_839 | The Kicker's Union | age 38-41 | once |  |  |  | R1 no age cap (ages 39-41; 38 plays now) |

- **PRO_143 Forty**: You turn forty in camp. The rookies were in diapers when you kicked in high school.
- **PRO_150 The Note in the Locker**: A rookie leaves a note in your locker: he grew up watching you. *(Age 38 is reachable now (the cap retires a player after the age-38 season); ages above wait on R1.)*
- **PRO_176 Contract Year: The Phone Call Every Spring**: At your age the club offers one year at a time, and every spring you wait by the phone to hear if there's another.
- **PRO_181 The Slump Nobody Waits Out**: At this age, a club doesn't wait for you to work it out. The backup is already kicking where the coaches can see.
- **PRO_186 The Oldest Streak**: A perfect month at your age. The league office sends a statistician to make sure it's real.
- **PRO_189 The Kid in Your Seat**: The club drafts a kicker who was in grade school when you signed your first contract.
- **PRO_194 Six Weeks at Your Age**: Six weeks on the shelf at your age is a season. The club starts working out kickers on Tuesdays.
- **PRO_198 The Last Stop?**: Your fourth club. Everyone in the building assumes it's the last one, including you.
- **PRO_217 Graduation Day**: Your kid's graduation lands on a road trip.
- **PRO_308 Kicking in Your Forties**: Turning forty in the league: a birthday cake in the locker room and a question in every interview.
- **PRO_465 The Oldest Player in the League**: You become the oldest active player in the league.
- **PRO_466 The One-Year Contract**: Another one-year deal, offered with a shrug.
- **PRO_467 The Recovery Challenge**: Your body needs two days to do what used to take one.
- **PRO_468 The Record Chase**: You're close to an all-time kicking record.
- **PRO_469 The Former Teammate's Induction**: A former teammate is inducted into the Hall of Fame.
- **PRO_470 The Friend's Retirement**: A close friend in the league announces his retirement.
- **PRO_471 The Agent's Final Pitch**: Your agent works the phones for one more opportunity.
- **PRO_472 The Team's Salary Decision**: The club decides whether your experience is worth your salary.
- **PRO_473 The Younger Kicker's Challenge**: A rookie says, to your face, that you can't compete anymore.
- **PRO_474 The Old Stadium**: You play in a stadium where you kicked as a rookie.
- **PRO_475 The Jersey Recognition**: A former club wants to honor your career.
- **PRO_476 The Retirement Interview**: A broadcaster asks you for a retirement date, on air.
- **PRO_477 The Specialists Job**: A club offers you a job coaching its specialists.
- **PRO_478 The Broadcasting Contract**: A network offers you a full-time job.
- **PRO_479 The Family Reunion**: Your family wants to celebrate your career, together.
- **PRO_480 The Empty House**: The kids have moved out, and the house is very quiet.
- **PRO_481 The Financial Freedom Question**: You ask whether you have enough to stop.
- **PRO_482 Partners in Something New**: A former teammate wants you as a partner.
- **PRO_483 Opening an Academy**: You consider opening a training academy.
- **PRO_484 The Old Rival's Message**: {tyler} writes to look back on both careers.
- **PRO_485 The Hall of Fame Discussion**: Analysts begin discussing your Hall of Fame chances.
- **PRO_486 The Final Jersey**: A club asks you to donate a jersey for its collection.
- **PRO_487 The New Generation of Kickers**: Young kickers keep telling you they grew up watching you.
- **PRO_488 One Last Negotiation**: What could be your last contract negotiation.
- **PRO_489 The Family's Concern**: Your family wants you to stop putting your body through this.
- **PRO_490 The Longest Career Record**: You could set a longevity record.
- **PRO_491 The Old Training Routine**: You can't train the way you did at twenty-five.
- **PRO_492 A Program for Former Players**: You consider a program for former players.
- **PRO_493 The Former Coach's Legacy**: You reconnect with the coach who launched your career.
- **PRO_494 The Franchise's Tribute**: Your club recognizes your years of service.
- **PRO_495 The Young Coach's Challenge**: A young coach questions whether your experience still matters.
- **PRO_496 The Free Agency Wait**: The first week at a new club, after a spring of waiting for the phone to ring.
- **PRO_497 One Last Offseason**: Your family hopes this is the last offseason of preparing for another season.
- **PRO_498 The Retirement Financial Plan**: You start moving your finances toward life after football.
- **PRO_499 The Hometown Statue Proposal**: Your hometown is considering a statue.
- **PRO_500 The Team Ambassador Role**: A club offers you a job as its ambassador.
- **PRO_501 The Last Locker Room Speech**: Younger teammates ask you to speak before the season.
- **PRO_502 The Retirement Announcement Question**: Your family asks whether you've decided.
- **PRO_503 The Former Rival's Retirement**: The last player from your original generation retires.
- **PRO_504 The Next Chapter Contract**: A club offers you a non-playing role.
- **PRO_505 The Legacy Foundation**: You consider a foundation for young athletes.
- **PRO_506 The Final Decision**: You decide whether to come back for another season.
- **PRO_812 The Thirty-Eighth Camp**: Another camp, and the rookies are taking selfies with you.
- **PRO_813 The Oldest Locker**: Your locker is the oldest one in the building, and the equipment manager wants to retire it.
- **PRO_814 The Doctors' Second Opinion**: Two doctors disagree about whether you should play another season.
- **PRO_815 The Medical Clearance**: The club's doctors clear you, but only after a week of tests.
- **PRO_816 The Recovery Pool**: You spend more time in the recovery pool than on the practice field.
- **PRO_817 The Grandparent Question**: {parent} asks when he'll get to see you retire.
- **PRO_818 The Grandchild**: You become a grandparent, and you're still kicking.
- **PRO_819 The Kid in College**: Your kid's college games and your games are on the same weekends.
- **PRO_820 The Family's Last Road Trip**: Your whole family travels to a road game together.
- **PRO_821 Another Make-or-Break Year**: Another contract year that might be the last.
- **PRO_822 The League's Oldest Kickers**: A list of the oldest kickers in league history, and your name is climbing it.
- **PRO_823 The Rule You Remember**: A rule change reminds you how long you've been around.
- **PRO_824 The Former Teammate as Head Coach**: A former teammate becomes a head coach, and he's younger than you.
- **PRO_825 The Kicker You Watched Retire**: A kicker you watched as a kid has a statue unveiled, and you're invited.
- **PRO_826 The Night Practice**: A night practice at your age, and the cold gets into your joints.
- **PRO_827 The New Recovery Tech**: The club buys new recovery technology, and you're the first to try it.
- **PRO_828 The Gala in Your Honor**: Your foundation's gala honors your career while you're still playing.
- **PRO_829 The Retirement Present**: Teammates buy you a retirement present before you've retired.
- **PRO_830 The Last Contract Signing**: You sign what everyone assumes is your last contract.
- **PRO_831 The Long Snapper's Retirement**: The long snapper you've worked with for ten years retires.
- **PRO_832 The Rival's Kid**: {tyler}'s kid is a kicker in college.
- **PRO_833 The Old College Coach's Funeral**: The coach who recruited you to college dies.
- **PRO_834 The Weight You Can't Lose**: You can't keep the weight off the way you used to.
- **PRO_835 The Sleep You Need**: You need ten hours of sleep now, and the road trips don't allow it.
- **PRO_836 The Young Coach's Respect**: A young coach admits he learned from watching your film.
- **PRO_837 The Media's Last Questions**: Every press conference ends with the same question about retirement.
- **PRO_838 The Fan's Memory**: A fan shows you a ticket stub from your first pro game.
- **PRO_839 The Kicker's Union**: You help start a group for kickers and punters to talk about health.

## Era 6: Hall of Fame Era (42+) (40)

| ID | Title | Window | Kind | Opens on | Sets | Callbacks (locked choices) | Waits on |
|---|---|---|---|---|---|---|---|
| PRO_144 | Still the Oldest | age 42+ | once |  |  |  | R1 no age cap |
| PRO_177 | Contract Year: Nobody This Old | age 42+ | variant | contract_year |  |  | R1 no age cap |
| PRO_182 | The Last Slump | age 42+ | variant | slump_now 1+ |  | saw_sports_psych, leaned_on_support | R1 no age cap |
| PRO_187 | A Legend's Month | age 42+ | variant | fg_streak 8+ |  |  | R1 no age cap |
| PRO_190 | Your Replacement Was Born the Year You Turned Pro | age 42+, weeks 1-3 | variant |  |  |  | R1 no age cap |
| PRO_195 | One More Comeback | age 42+ | variant | injured_now 1+ |  | committed_to_recovery, hid_injury | R1 no age cap |
| PRO_199 | Signed at Your Age | age 42+ | variant | signed_new_club |  |  | R1 no age cap |
| PRO_507 | The Historic Contract | age 42+ | once | contract_year |  |  | R1 no age cap |
| PRO_508 | The Record-Breaking Career | age 42+ | once | pro_seasons 18+ |  |  | R1 no age cap |
| PRO_509 | The Hall of Fame Debate | age 42+ | once | pro_seasons 18+ |  |  | R1 no age cap |
| PRO_510 | The Retirement Question | age 42+ | once |  |  |  | R1 no age cap |
| PRO_511 | The Young Kicker's Inspiration | age 42+ | once |  |  |  | R1 no age cap |
| PRO_512 | The Final Contract Offer | age 42+ | once | contract_year |  |  | R1 no age cap |
| PRO_513 | The Franchise Legend | age 42+ | once |  |  |  | R1 no age cap |
| PRO_514 | The Jersey Retirement Discussion | age 42+ | once |  |  |  | R1 no age cap |
| PRO_515 | The All-Time Record | age 42+ | once | pro_seasons 18+ |  |  | R1 no age cap |
| PRO_516 | The Longevity Record | age 42+ | once | pro_seasons 19+ |  |  | R1 no age cap |
| PRO_517 | The Documentary Premiere | age 42+ | once |  |  |  | R1 no age cap |
| PRO_518 | A Night in the Hall | age 42+ | once |  |  |  | R1 no age cap |
| PRO_519 | The Hall of Fame Dinner | age 42+ | once |  |  |  | R1 no age cap |
| PRO_520 | The Final Road Game | age 42+ | once |  |  |  | R1 no age cap |
| PRO_521 | The Team's Tribute Video | age 42+ | once |  |  |  | R1 no age cap |
| PRO_522 | The New Generation | age 42+ | once |  |  |  | R1 no age cap |
| PRO_523 | The Coaching Job | age 42+ | once |  |  |  | R1 no age cap |
| PRO_524 | The Analyst Offer | age 42+ | once |  |  |  | R1 no age cap |
| PRO_525 | The Front Office | age 42+ | once |  |  |  | R1 no age cap |
| PRO_526 | The Retirement Financial Review | age 42+ | once |  |  |  | R3 money values; R1 no age cap |
| PRO_527 | The Family's Final Request | age 42+ | once |  |  |  | R1 no age cap |
| PRO_528 | The Grandchild's Game | age 42+ | once | became_parent |  |  | R1 no age cap |
| PRO_529 | The Hometown Celebration | age 42+ | once |  |  |  | R1 no age cap |
| PRO_530 | The Hall Visit | age 42+ | once |  |  |  | R1 no age cap |
| PRO_531 | The Historic Stadium Return | age 42+ | once |  |  |  | R1 no age cap |
| PRO_532 | The Final Training Camp | age 42+ | once |  |  |  | R1 no age cap |
| PRO_533 | The Rookie's Question | age 42+ | once |  |  |  | R1 no age cap |
| PRO_534 | The Veteran's Legacy | age 42+ | once |  |  |  | R1 no age cap |
| PRO_535 | The Final Free Agency | age 42+, club season 1, weeks 1-3 | once | signed_new_club + released |  |  | R1 no age cap |
| PRO_536 | Planning the Goodbye | age 42+ | once |  |  |  | R1 no age cap |
| PRO_537 | The Final Season Decision | age 42+, offseason | once |  |  |  | R1 no age cap |
| PRO_538 | The Former Coach's Recognition | age 42+ | once |  |  |  | R1 no age cap |
| PRO_539 | The All-Time Greats Dinner | age 42+ | once |  |  |  | R1 no age cap |

- **PRO_144 Still the Oldest**: You've been the oldest player in the league for years now, and a reporter asks how long.
- **PRO_177 Contract Year: Nobody This Old**: No kicker your age has signed a contract in years. Your agent says the league is curious, and the general manager says 'prove it'.
- **PRO_182 The Last Slump**: You've survived a dozen slumps. This one feels different, and you know exactly why.
- **PRO_187 A Legend's Month**: Kids who weren't born when you started are wearing your jersey to practice.
- **PRO_190 Your Replacement Was Born the Year You Turned Pro**: The new kicker's mother asks for your autograph at camp. For herself.
- **PRO_195 One More Comeback**: The doctors are polite about it, which is how you know.
- **PRO_199 Signed at Your Age**: The press conference is bigger than the contract. Everybody wants to see the oldest kicker in the league sign the papers.
- **PRO_507 The Historic Contract**: A club offers you another contract, at an age nobody signs.
- **PRO_508 The Record-Breaking Career**: You're approaching the league's all-time scoring record.
- **PRO_509 The Hall of Fame Debate**: Analysts argue about whether your career belongs in the Hall of Fame.
- **PRO_510 The Retirement Question**: A reporter asks if this is your final season.
- **PRO_511 The Young Kicker's Inspiration**: A rookie says you're the reason he started kicking.
- **PRO_512 The Final Contract Offer**: An offer that could extend your career one more year.
- **PRO_513 The Franchise Legend**: A former club wants to recognize what you gave it.
- **PRO_514 The Jersey Retirement Discussion**: A club discusses retiring your number once you're done.
- **PRO_515 The All-Time Record**: You could become the league's career scoring leader.
- **PRO_516 The Longevity Record**: You're close to the record for most seasons by a kicker.
- **PRO_517 The Documentary Premiere**: The documentary about your career premieres.
- **PRO_518 A Night in the Hall**: Someone you played with is inducted into the Hall of Fame.
- **PRO_519 The Hall of Fame Dinner**: You're invited to a dinner for the league's greats.
- **PRO_520 The Final Road Game**: Your family comes along for what could be your last road trip.
- **PRO_521 The Team's Tribute Video**: Teammates and coaches put together a tribute.
- **PRO_522 The New Generation**: A young kicker asks you to be his mentor.
- **PRO_523 The Coaching Job**: A club offers you a coaching position.
- **PRO_524 The Analyst Offer**: A network wants you as its lead football analyst.
- **PRO_525 The Front Office**: A club discusses a front-office job with you.
- **PRO_526 The Retirement Financial Review**: You review whether you're ready to stop.
- **PRO_527 The Family's Final Request**: Your family asks you to spend more time at home.
- **PRO_528 The Grandchild's Game**: A grandchild wants you at an important game.
- **PRO_529 The Hometown Celebration**: Your hometown throws a celebration of your career.
- **PRO_530 The Hall Visit**: You visit the Hall of Fame and look at the kickers on the wall.
- **PRO_531 The Historic Stadium Return**: You play at the stadium where your career began.
- **PRO_532 The Final Training Camp**: Another camp, and you wonder how many remain.
- **PRO_533 The Rookie's Question**: A rookie asks how you lasted this long.
- **PRO_534 The Veteran's Legacy**: You speak to a room of young athletes.
- **PRO_535 The Final Free Agency**: The first week at a new club, after a spring nobody expected you to survive.
- **PRO_536 Planning the Goodbye**: You start planning how you'd announce it.
- **PRO_537 The Final Season Decision**: You decide whether to keep going.
- **PRO_538 The Former Coach's Recognition**: An old coach credits you publicly for your longevity.
- **PRO_539 The All-Time Greats Dinner**: A private dinner with legends of the game.

## Across eras (state-driven) (108)

| ID | Title | Window | Kind | Opens on | Sets | Callbacks (locked choices) | Waits on |
|---|---|---|---|---|---|---|---|
| PRO_016 | The Slump | any | repeat | slump_now 1+ |  | saw_sports_psych, leaned_on_support |  |
| PRO_017 | The Coach Loses Faith | any | repeat | slump_now 1+ |  |  |  |
| PRO_018 | Benched | any | repeat | benched_now 1+ |  |  |  |
| PRO_019 | The Job Back | any | repeat | won_job_back |  |  |  |
| PRO_020 | The Hot Streak | any | repeat | fg_streak 6+ |  |  |  |
| PRO_024 | Talk Radio | any | once | slump_now 1+ |  |  |  |
| PRO_025 | The Yips | any | once | slump_now 1+ |  | saw_sports_psych, got_help_panic |  |
| PRO_027 | The Film That Hurts | any | once | slump_now 1+ |  |  |  |
| PRO_028 | Kicking Hurt | any | repeat | injured_now 1+ |  | committed_to_recovery, hid_injury |  |
| PRO_033 | Playing for a Contract | any | once | contract_year |  |  |  |
| PRO_039 | The Re-Sign Call | any | repeat | re_signed |  |  |  |
| PRO_042 | Starting Over | club season 1, weeks 1-3 | once | signed_new_club + released |  |  |  |
| PRO_043 | New Club, New Locker Room | club season 1, weeks 1-2 | per_club | signed_new_club |  |  |  |
| PRO_044 | A Holder at the New Club | club season 1, weeks 1-4 | per_club |  |  |  |  |
| PRO_045 | Packing Up the House | club season 1, offseason | per_club | signed_new_club |  |  |  |
| PRO_046 | The Family Stays Behind | club season 1 | once | signed_new_club |  |  |  |
| PRO_047 | Your Old Team Comes to Town | any | once | clubs 2+ |  |  |  |
| PRO_049 | Firing Your Agent | any | once | agent_neglect | fired_agent |  |  |
| PRO_051 | The Tryout Hotel | club season 1 | once | signed_new_club |  |  |  |
| PRO_059 | The Missing Money | any | once | trusted_flashy_advisor | advisor_stole, hid_the_loss |  | R3 money values (-0.4) |
| PRO_060 | The Lawsuit | any | once | advisor_stole | sued_advisor |  | R3 money values |
| PRO_062 | The Restaurant Is Failing | any | once | opened_restaurant | bad_venture | honest_advisor | R3 money values |
| PRO_065 | The Start-Up Calls | any | once | invested_in_friend |  | honest_advisor | R3 money values |
| PRO_067 | Family Asks for Money | any | repeat |  |  |  | R3 money values |
| PRO_074 | The Proposal | any | once | made_long_distance_work / committed_to_relationship / new_partner; not engaged / married; rel_love_interest 55+ | engaged |  |  |
| PRO_075 | The Wedding | offseason | once | engaged | married |  |  |
| PRO_076 | The Due Date | any | once | married / engaged | became_parent |  |  |
| PRO_078 | The Recital | any | repeat | became_parent |  |  |  |
| PRO_079 | Your Partner's Career | any | once | married / engaged |  |  |  |
| PRO_083 | The Old Friend's Ticket Requests | any | repeat |  |  |  |  |
| PRO_092 | A Teammate in Trouble | any | repeat |  |  |  |  |
| PRO_095 | The Tabloid | any | once | married |  |  |  |
| PRO_096 | The Marriage on the Road | any | once | married | marriage_strained |  |  |
| PRO_099 | The Locker Room Fight | any | repeat |  |  |  |  |
| PRO_104 | The Labor Fight | any | once | player_rep |  |  |  |
| PRO_108 | The Autograph Session | any | repeat | tier verified |  |  |  |
| PRO_113 | The Playoff Push | weeks 8-11 | repeat |  |  |  |  |
| PRO_114 | A Season Going Nowhere | weeks 6-11 | repeat |  |  |  |  |
| PRO_116 | After the Game | any | once |  | pro_night_out |  |  |
| PRO_117 | The Supplement Sponsor | any | once |  | pro_unapproved_supplement |  |  |
| PRO_118 | The Video | any | once |  | pro_bar_fight |  |  |
| PRO_119 | The Friend Who Bets | any | once |  | pro_shared_inside_info |  |  |
| PRO_120 | The Party House | any | once |  | pro_party_house |  |  |
| PRO_121 | The New Car | any | once |  | pro_reckless_driving | street_race |  |
| PRO_122 | The Rant | any | once |  | pro_online_rant | online_incident, handled_old_post |  |
| PRO_123 | The Card Game | any | once |  | pro_gambling_debt |  | R3 money values |
| PRO_124 | The Team Fine | story | once | (every pro strike) | pro_warning, pro_owned_it | owned_mistake, rebuilt_reputation, character_concerns |  |
| PRO_125 | League Discipline | story | once | pro_warning; (every pro strike) | pro_second_chance, pro_character_concerns |  |  |
| PRO_126 | The Last Warning, Pro | story | once | pro_second_chance; (every pro strike) | pro_last_chance, pro_character_concerns | last_chance |  |
| PRO_127 | Released for Conduct | any | once | pro_last_chance; new pro strike | dismissed |  |  |
| PRO_128 | Earning It Back | story | once | pro_character_concerns | pro_rebuilt_reputation |  |  |
| PRO_129 | The League's Counselor | any | once | pro_second_chance / pro_last_chance |  |  |  |
| PRO_130 | A Clean Year | any | once | pro_owned_it / pro_rebuilt_reputation |  |  |  |
| PRO_151 | Love Again | any | repeat | ended_long_distance / dating_classmate / broke_up_pro / divorced; not new_partner / engaged / married | new_partner, enjoying_single_life | dating_classmate | R8 re-point {love_interest} |
| PRO_152 | The Setup | any | once | not made_long_distance_work / committed_to_relationship / new_partner / engaged / married / dating_classmate |  |  |  |
| PRO_153 | The Profile | any | once | not made_long_distance_work / committed_to_relationship / new_partner / engaged / married / dating_classmate |  |  |  |
| PRO_154 | The Famous Date | any | once | not made_long_distance_work / committed_to_relationship / new_partner / engaged / married / dating_classmate |  |  |  |
| PRO_155 | The Fan | any | once | new_partner; not engaged / married | pro_cheated |  |  |
| PRO_156 | The Hotel Bar | any | once | made_long_distance_work / committed_to_relationship; not engaged / married | pro_cheated |  |  |
| PRO_157 | The Sponsor's Rep | any | once | engaged; not married | pro_cheated, affair_public |  |  |
| PRO_158 | The Teammate's Friend | any | once | married; not became_parent | pro_cheated |  |  |
| PRO_159 | The Long Week on the Road | any | once | married + became_parent | pro_cheated |  |  |
| PRO_160 | Found Out | any | once | pro_cheated | confessed_affair, lied_about_affair |  |  |
| PRO_161 | The Lie Comes Out | any | once | lied_about_affair | affair_public, broke_up_pro |  |  |
| PRO_162 | Starting Over, Together | any | once | confessed_affair | repaired_relationship, broke_up_pro |  |  |
| PRO_163 | The Divorce | any | once | married; lied_about_affair / affair_public / confessed_affair / marriage_strained | divorced |  | R3 money values |
| PRO_164 | The Package | any | once |  | pro_banned_substance, reported_package | took_unapproved_supplement, refused_improper_help |  |
| PRO_165 | The Search | any | once | pro_banned_substance | pro_caught_with_package |  |  |
| PRO_166 | The Night Before | any | once |  | pro_night_before |  |  |
| PRO_167 | Late for the Meeting | any | repeat |  | pro_late_meeting, late_fined |  |  |
| PRO_168 | Late Again | any | once | late_fined | pro_late_meeting, late_warned |  |  |
| PRO_169 | The Depth Chart Note | any | once | late_warned | pro_late_meeting |  |  |
| PRO_170 | The Office Pool | any | once |  | pro_casual_bet |  |  |
| PRO_171 | The Bookie | any | once |  | pro_betting_scandal, reported_bookie | refused_improper_help, reported_runner |  |
| PRO_172 | The Investigation | any | once | pro_betting_scandal | pro_character_concerns |  |  |
| PRO_173 | The Spa | any | once |  | pro_solicitation |  |  |
| PRO_174 | The Hearing | any | once | pro_solicitation; not made_long_distance_work / committed_to_relationship / new_partner / engaged / married | pro_hearing_done |  |  |
| PRO_175 | The Hearing, at Home | any | once | pro_solicitation; made_long_distance_work / committed_to_relationship / new_partner / engaged / married | pro_hearing_done, pro_cheated |  |  |
| PRO_200 | The Yearly Media Session | weeks 1-1 | repeat |  |  |  |  |
| PRO_201 | Camp Opens | weeks 1-1 | repeat |  |  |  |  |
| PRO_203 | The Charity Kick | any | repeat |  |  |  |  |
| PRO_204 | Bye Week at Home | any | repeat |  |  |  |  |
| PRO_205 | The Offseason Plan | offseason | repeat |  |  |  |  |
| PRO_206 | The Film Room | any | repeat |  |  |  |  |
| PRO_207 | The Fan Letter | any | repeat |  |  |  |  |
| PRO_208 | The Locker Room Prank | any | repeat |  |  |  |  |
| PRO_209 | The Holder's Birthday | any | repeat |  |  |  |  |
| PRO_210 | Road Trip Routine | any | repeat |  |  |  |  |
| PRO_211 | The Contract Talk at Home | any | repeat | made_long_distance_work / committed_to_relationship / new_partner / engaged / married; contract_years_left 1+ |  |  |  |
| PRO_213 | Playoff Atmosphere | weeks 8-11 | repeat |  |  |  |  |
| PRO_214 | Your Kid's First Game | any | once | became_parent |  |  |  |
| PRO_233 | The Business Grows | any | once | invested_in_friend |  |  | R3 money values |
| PRO_234 | The Partner Who Cheats You | any | once | dealership_partner | business_fraud_victim |  | R3 money values |
| PRO_236 | Selling the Business | any | once | franchise_owner / started_foundation |  |  | R3 money values |
| PRO_244 | One More Year? | offseason | once | planning_retirement | chose_one_more_year |  |  |
| PRO_245 | Choosing One More Year | any | once | chose_one_more_year |  |  |  |
| PRO_246 | The General Manager's Call | any | once | pro_seasons 4+; retention under 40 |  |  |  |
| PRO_247 | Forced Out | any | once | released; pro_seasons 5+ |  |  |  |
| PRO_248 | The Announcement | any | once | planning_retirement | announced_retirement |  |  |
| PRO_249 | The Last Road Trip | weeks 6-11 | once | announced_retirement |  |  |  |
| PRO_250 | The Last Home Week | weeks 8-11 | once | announced_retirement |  |  |  |
| PRO_251 | Thank You, {holder} | any | once | planning_retirement |  |  |  |
| PRO_252 | The Family Vote | any | once | made_long_distance_work / committed_to_relationship / new_partner / engaged / married; pro_seasons 5+ |  |  |  |
| PRO_254 | The Exit Interview | offseason | once | pro_seasons 6+ |  |  |  |
| PRO_255 | The Retirement Party | any | once | planning_retirement |  |  |  |
| PRO_257 | Changing Your Mind | any | once | announced_retirement |  |  |  |
| PRO_258 | The Last Kick in Practice | weeks 9-11 | once | announced_retirement |  |  |  |
| PRO_282 | The Last Summer | offseason | once | planning_retirement |  |  |  |

- **PRO_016 The Slump**: Three weeks of misses in practice and the coaches have stopped talking to you about it, which is worse. *(Repeatable (cooldown 15 weeks). Locks open with experience (kick_slumps, age).)*
- **PRO_017 The Coach Loses Faith**: {coach} watches your warmup with folded arms and doesn't say a word.
- **PRO_018 Benched**: You're inactive this week. Your name is on the board, and your helmet is in your locker. *(Every engine flag is sticky from high school, so the present-state check is needed.)*
- **PRO_019 The Job Back**: You're active again. The kicker who replaced you is clearing out his stall.
- **PRO_020 The Hot Streak**: You haven't missed in a month, and everyone wants to talk about it except you.
- **PRO_024 Talk Radio**: The afternoon talk show has a segment called 'Cut the Kicker', and your {parent} listens to it every day.
- **PRO_025 The Yips**: Your foot won't swing through the ball in practice. Not tired, not hurt, just stuck.
- **PRO_027 The Film That Hurts**: {coach} plays every miss of your season back to back in an empty meeting room.
- **PRO_028 Kicking Hurt**: Your plant leg is sore in a way the trainers can't find on a scan.
- **PRO_033 Playing for a Contract**: Every kick in practice now feels like a negotiation.
- **PRO_039 The Re-Sign Call**: The club wants you back. Your agent wants to wait for the market.
- **PRO_042 Starting Over**: The last club let you go. A week ago you were cleaning out a locker; today you're in a stranger's locker room in a city you've never visited. *(Opens after any release or cut (the engine's failed_tryouts list), in the first weeks at the next club. Tone-check scene (being cut at the end of camp).)*
- **PRO_043 New Club, New Locker Room**: First day at {club}. Your name is on tape above a locker that still has someone else's sticker on it.
- **PRO_044 A Holder at the New Club**: {holder} spins the laces differently than anyone you've worked with.
- **PRO_045 Packing Up the House**: The new contract is in {town}. Your partner has a job and friends where you live now.
- **PRO_046 The Family Stays Behind**: You'll be in {town} during the season, and your family will be a flight away.
- **PRO_047 Your Old Team Comes to Town**: Your old club is on the schedule. Half the locker room over there still texts you.
- **PRO_049 Firing Your Agent**: Your agent has missed two deadlines this year. Firing him means starting over with someone new.
- **PRO_051 The Tryout Hotel**: You got the job at a Tuesday tryout. Now you live in a hotel by the airport until somebody says otherwise.
- **PRO_059 The Missing Money**: Your accounts are lighter than they should be, and the advisor isn't answering. *(Works now with flags and stress; the stolen 40% lands with R3.)*
- **PRO_060 The Lawsuit**: Your lawyer says you can sue the advisor. It'll take three years and your name will be in every story.
- **PRO_062 The Restaurant Is Failing**: The steakhouse is losing money every week, and your name is on the sign.
- **PRO_065 The Start-Up Calls**: {best_friend}'s company is either about to make it or about to fold, and they need one more check. *(The one good venture: it can pay off.)*
- **PRO_067 Family Asks for Money**: {sibling} needs money and doesn't want {parent} to know.
- **PRO_074 The Proposal**: You've been carrying a ring around for three weeks, waiting for the right moment that won't come during a season.
- **PRO_075 The Wedding**: The wedding is in the offseason. The guest list is a fight.
- **PRO_076 The Due Date**: The baby is due the same week as a road game across the country.
- **PRO_078 The Recital**: A school recital, a road trip, and a kid who has asked three times if you'll be there.
- **PRO_079 Your Partner's Career**: Your partner has been offered the job of a lifetime, in a city with no team.
- **PRO_083 The Old Friend's Ticket Requests**: {best_friend} asks for tickets every week and brings a different stranger every time. *(Repeatable (cooldown 15-20 weeks).)*
- **PRO_092 A Teammate in Trouble**: A teammate's arrest is on every channel. He asks you to vouch for him at the hearing. *(Repeatable (cooldown 15-20 weeks).)*
- **PRO_095 The Tabloid**: A gossip site prints a story about your marriage that's mostly made up.
- **PRO_096 The Marriage on the Road**: You've been home eleven nights since August, and your partner has stopped asking when you'll be back.
- **PRO_099 The Locker Room Fight**: Two starters are swinging at each other by the cold tub, and the rookies are watching you. *(Repeatable (cooldown 15-20 weeks).)*
- **PRO_104 The Labor Fight**: The league and the union are fighting over the next agreement, and the owners are talking about replacement players. *(Told through teammates; no strike mechanic.)*
- **PRO_108 The Autograph Session**: A mall signing goes three hours over, and the line still wraps around the food court. *(Repeatable (cooldown 15-20 weeks).)*
- **PRO_113 The Playoff Push**: The city has noticed the team. Everyone wants a piece of the players in the last month. *(No results; the push is the atmosphere. Repeatable (cooldown 15-20 weeks).)*
- **PRO_114 A Season Going Nowhere**: The season's slipping away, and the locker room has started counting days until the offseason. *(Repeatable (cooldown 15-20 weeks).)*
- **PRO_116 After the Game**: A teammate's night out after a home game starts at a club and ends somewhere you don't want to be. *(Strike. Clean no.)*
- **PRO_117 The Supplement Sponsor**: A supplement company offers you a deal for a product the league hasn't approved.
- **PRO_118 The Video**: Someone at a bar is filming you while a stranger tries to start a fight.
- **PRO_119 The Friend Who Bets**: An old friend who bets on games asks what you know about the starting quarterback's ankle. *(Integrity strike: the worst one.)*
- **PRO_120 The Party House**: A teammate rents a house for the bye week, and the guest list is long.
- **PRO_121 The New Car**: Your new car does zero to sixty in three seconds, and the highway is empty at midnight.
- **PRO_122 The Rant**: It's two in the morning and you've written four paragraphs about the general manager.
- **PRO_123 The Card Game**: The card game in the back of the team plane has a buy-in bigger than your first car.
- **PRO_124 The Team Fine**: The club fines you and calls you in. The special teams coach is there, and so is the general manager. *(Both choices set pro_warning (the fine is on record); owning it also sets pro_owned_it. College flags set severity through a locked choice. Every choice clears every pro strike.)*
- **PRO_125 League Discipline**: The league office wants a meeting. It's not a conversation; it's a hearing. *(Opens on the warning plus a new pro strike. suspend_weeks 2 (longer once R9 lands). Every choice clears every pro strike.)*
- **PRO_126 The Last Warning, Pro**: The general manager says it plainly: one more and you're done here. *(Every choice clears every pro strike. College last_chance adds a locked line.)*
- **PRO_127 Released for Conduct**: After a last chance, another strike: the club is done with you. *(Sets the dismissal flag; the release happens at season end once R7 lands.)*
- **PRO_128 Earning It Back**: A new club, a short contract, and a list of conditions longer than the playbook.
- **PRO_129 The League's Counselor**: The league assigns you a counselor after the hearing, and the first session is Tuesday.
- **PRO_130 A Clean Year**: A full year without a fine, a headline or a hearing. The general manager notices.
- **PRO_151 Love Again**: You're single in a new city, or the person you dated in college has followed you here, and it's starting to feel serious. *(One scene for both paths: a player who ended things with the high school love interest meets someone new; a player who dated the college classmate makes the classmate the pro partner (locked choice). Committing re-points {love_interest} to the new partner (R8). Repeats after a breakup or divorce (cooldown 15 weeks).)*
- **PRO_152 The Setup**: A teammate's wife has decided you need to meet her friend, and dinner is Saturday whether you like it or not. *(Single, dating around; no cheating framing.)*
- **PRO_153 The Profile**: Someone screenshots your dating profile and it ends up on a fan account with a caption you didn't write.
- **PRO_154 The Famous Date**: You're photographed at dinner with someone famous, and by morning the internet has decided you're engaged. *(Followers up; the date has opinions about your schedule.)*
- **PRO_155 The Fan**: A fan who's been at every signing this season slips you a hotel key card with your autograph. *(Dating stage. Strike: pro_cheated.)*
- **PRO_156 The Hotel Bar**: After a road game, the team hotel's bar. Someone who isn't {love_interest} has been talking to you for an hour and doesn't want the night to end. *(Committed stage (still with the high school love interest). Tone-check scene.)*
- **PRO_157 The Sponsor's Rep**: The rep from your biggest sponsor has handled your account for a year. Tonight the dinner is just the two of you, and she suggests a nightcap at her hotel. *(Engaged stage. Going public costs the sponsor (scandal).)*
- **PRO_158 The Teammate's Friend**: A teammate's friend keeps showing up at the team's Thursday dinners, and keeps sitting next to you. *(Married stage.)*
- **PRO_159 The Long Week on the Road**: Two road games back to back, ten days from home, and a woman at the team hotel who knows exactly who you are and doesn't care that you're married. *(Married with kids. The kids appear only in the text.)*
- **PRO_160 Found Out**: {love_interest} has your phone in one hand and a question in the other. *(Story event, soon after the strike. Confess: costs now, keeps the door open. Lie: worse when it surfaces.)*
- **PRO_161 The Lie Comes Out**: The story you told {love_interest} has just fallen apart, in a text from someone you've never met. *(Breaking up clears every partner flag (made_long_distance_work, committed_to_relationship, new_partner, engaged).)*
- **PRO_162 Starting Over, Together**: {love_interest} agrees to see a counselor with you. The first session is Thursday, and the counselor asks who wants to go first.
- **PRO_163 The Divorce**: The lawyers have the paperwork ready, and {love_interest} wants to talk before anyone signs anything. *(Divorce clears married and the other partner flags; the money cost lands with savings (R3). People: kids in the text only.)*
- **PRO_164 The Package**: A trainer from a private gym you used last summer leaves a package in your locker: a banned substance, a note that says it can't be detected, and his number. *(The player is never shown taking anything: the wrong choice is keeping the package and saying nothing. Clean no: the team doctor or the league's confidential line. Tone-check scene.)*
- **PRO_165 The Search**: League testers arrive unannounced and ask to see your locker and your gym bag. The package is still in it. *(Follow-up to The Package: a possession case, not a positive test, so the player is never shown taking anything. Costs: suspend_weeks (3 now; longer once R9 lands), retention, followers, conduct scandal (sponsors drop the player).)*
- **PRO_166 The Night Before**: The night before a game, a teammate's dinner (or your agent's dinner for his clients) moves to a strip club, and the whole table is getting up. *(Non-explicit: the scene ends at the choice, and the bad choice cuts to the next morning. Costs: photos online (followers, conduct bad), tired / late_night into the game, {coach}; {love_interest} only through a locked or follow-up line if the player has a partner (partner flags). No game result.)*
- **PRO_167 Late for the Meeting**: The special teams meeting started at eight. It's 8:06, and you're in the parking lot. *(Escalation, step 1: the fine. Repeatable (cooldown 15 weeks); the escalating text lives in 168 and 169.)*
- **PRO_168 Late Again**: Late again. This time {coach} is waiting outside the meeting room, and the fine isn't the topic. *(Escalation, step 2: the talking-to.)*
- **PRO_169 The Depth Chart Note**: A third late arrival. There's a note on your locker: see {coach} before you dress. *(Escalation, step 3: inactive for a game (suspend_weeks 1, the club's discipline). Feeds the pro discipline chain through pro_late_meeting.)*
- **PRO_170 The Office Pool**: The locker room runs a pool on the college basketball tournament: twenty dollars a sheet and a lot of trash talk. *(Small strike: league rules forbid it, even on other sports. Conduct bad, a small fine, {coach}. Clean no with a payoff.)*
- **PRO_171 The Bookie**: An old friend from home introduces you to a man who takes bets, including on football, including on your own team's games. He'd also pay well for a heads-up on who's hurt. *(The most serious scandal: no how-to, no glamorous win. Clean no: walk away and call the league's integrity line. Tone-check scene.)*
- **PRO_172 The Investigation**: Two investigators from the league office are in the general manager's conference room, and they've asked for you by name. *(Follow-up: suspend_weeks 3 (the cap), retention, followers, scandal; character concerns for the pros (pro_character_concerns). Release follows through the discipline chain (R7).)*
- **PRO_173 The Spa**: On a road trip, an agent's client insists you come to a spa he swears by, and makes it clear the 'extras' are the point. *(Non-explicit: nothing is described, and the scene ends at the choice. Several clean no's, each with a payoff: book the team's therapist instead, tell him it isn't for you, or call the partner from the lobby (locked to partner flags). Paying cuts to later: a police investigation, a client list, a reporter's call. Strike: pro_solicitation (conduct scandal). Tone-check scene.)*
- **PRO_174 The Hearing**: A police report, a league hearing and a sponsor's lawyer, all in the same week. *(Follow-up for a player without a partner. League discipline: suspend_weeks (longer once R9 lands), sponsors pull out (conduct scandal), retention, followers.)*
- **PRO_175 The Hearing, at Home**: A police report, a league hearing and a sponsor's lawyer, all in the same week, and {love_interest} has read every word of it. *(Follow-up for a player with a partner: the same discipline, plus {love_interest} (-10 to -15). Every choice sets pro_cheated, so the Found Out chain picks it up.)*
- **PRO_200 The Yearly Media Session**: Media day, and the questions are the same every year. Your answers don't have to be. *(Repeatable (15-week cooldown). Locked choices open with experience: min pro_seasons 3 / 6 / 10, age, earlier flags.)*
- **PRO_201 Camp Opens**: The first day of camp. The rookies are terrified, the veterans are bored, and you're somewhere in between. *(Repeatable (15-week cooldown). Locked choices open with experience: min pro_seasons 3 / 6 / 10, age, earlier flags.)*
- **PRO_203 The Charity Kick**: The club's charity day: kids, cameras and a field goal for every dollar raised. *(Repeatable (15-week cooldown). Locked choices open with experience: min pro_seasons 3 / 6 / 10, age, earlier flags.)*
- **PRO_204 Bye Week at Home**: The bye week. Home for six days, and everyone wants a piece of them. *(Repeatable (15-week cooldown). Locked choices open with experience: min pro_seasons 3 / 6 / 10, age, earlier flags.)*
- **PRO_205 The Offseason Plan**: The offseason starts. You can rest, rebuild or chase something new. *(Repeatable (15-week cooldown). Locked choices open with experience: min pro_seasons 3 / 6 / 10, age, earlier flags.)*
- **PRO_206 The Film Room**: {coach} wants an extra film session with the specialists every Wednesday this month. *(Repeatable (15-week cooldown). Locked choices open with experience: min pro_seasons 3 / 6 / 10, age, earlier flags.)*
- **PRO_207 The Fan Letter**: A letter from a fan who has watched every kick of your career, good and bad. *(Repeatable (15-week cooldown). Locked choices open with experience: min pro_seasons 3 / 6 / 10, age, earlier flags.)*
- **PRO_208 The Locker Room Prank**: The locker room's annual prank war, and this year someone has made you the target. *(Repeatable (15-week cooldown). Locked choices open with experience: min pro_seasons 3 / 6 / 10, age, earlier flags.)*
- **PRO_209 The Holder's Birthday**: {holder}'s birthday, and the specialists have a tradition. *(Repeatable (15-week cooldown). Locked choices open with experience: min pro_seasons 3 / 6 / 10, age, earlier flags.)*
- **PRO_210 Road Trip Routine**: Another road trip, another hotel. Your routine is either a superpower or a rut. *(Repeatable (15-week cooldown). Locked choices open with experience: min pro_seasons 3 / 6 / 10, age, earlier flags.)*
- **PRO_211 The Contract Talk at Home**: Contract season again, and the conversation at the kitchen table sounds familiar. *(Repeatable (15-week cooldown). Locked choices open with experience: min pro_seasons 3 / 6 / 10, age, earlier flags.)*
- **PRO_213 Playoff Atmosphere**: The city has noticed the team again. Everyone wants a piece of the players. *(Repeatable (15-week cooldown). Locked choices open with experience: min pro_seasons 3 / 6 / 10, age, earlier flags.)*
- **PRO_214 Your Kid's First Game**: Your kid is in the stands for the first time, holding a sign with your name spelled wrong.
- **PRO_233 The Business Grows**: The start-up you backed is opening offices in three cities and wants your face on the launch.
- **PRO_234 The Partner Who Cheats You**: Your dealership partner has been cooking the books.
- **PRO_236 Selling the Business**: Someone wants to buy what you built, for more than you ever made kicking.
- **PRO_244 One More Year?**: The season's over. Your body says stop, your agent says one more, and nobody at home has said anything yet.
- **PRO_245 Choosing One More Year**: You chose one more year. Every practice now has a little countdown in it.
- **PRO_246 The General Manager's Call**: The general manager calls in March. It's a short call.
- **PRO_247 Forced Out**: They didn't say retire. They just stopped saying anything at all.
- **PRO_248 The Announcement**: How do you tell the world you're done?
- **PRO_249 The Last Road Trip**: The last road trip. The flight attendants have heard, and so has the hotel.
- **PRO_250 The Last Home Week**: The last home week of your career. The city knows, and so does every kid at practice.
- **PRO_251 Thank You, {holder}**: One last week of holds. {holder} has been counting them.
- **PRO_252 The Family Vote**: You put it to a family vote: one more season, or done.
- **PRO_254 The Exit Interview**: The club holds exit interviews after every season. This year the general manager is in yours.
- **PRO_255 The Retirement Party**: Your teammates throw a retirement party before you've even decided.
- **PRO_257 Changing Your Mind**: You announced it. Now you want to take it back.
- **PRO_258 The Last Kick in Practice**: The last kick of your last practice. Nobody leaves the field.
- **PRO_282 The Last Summer**: It might be your last offseason as a player. Every summer routine feels a little heavier.

## Epilogue (after retirement) (12)

| ID | Title | Window | Kind | Opens on | Sets | Callbacks (locked choices) | Waits on |
|---|---|---|---|---|---|---|---|
| PRO_E01 | Retirement Day | any | epilogue |  |  |  | R10 retirement epilogue stage |
| PRO_E02 | The Phone Call From the Club | any | epilogue |  |  |  | R10 retirement epilogue stage |
| PRO_E03 | Hall of Fame Eligibility | any | epilogue |  |  |  | R10 retirement epilogue stage |
| PRO_E04 | The Nomination | any | epilogue |  |  |  | R10 retirement epilogue stage |
| PRO_E05 | The Call | any | epilogue |  |  |  | R10 retirement epilogue stage |
| PRO_E06 | The Call That Doesn't Come | any | epilogue |  |  |  | R10 retirement epilogue stage |
| PRO_E07 | The Speech of a Lifetime | any | epilogue |  |  |  | R10 retirement epilogue stage |
| PRO_E08 | The Speech, Second Draft | any | epilogue |  |  |  | R10 retirement epilogue stage |
| PRO_E09 | The Look Back | any | epilogue |  |  |  | R10 retirement epilogue stage |
| PRO_E10 | The Kid With Your Number | any | epilogue |  |  |  | R10 retirement epilogue stage |
| PRO_E11 | Coach, Now | any | epilogue |  |  |  | R10 retirement epilogue stage |
| PRO_E12 | In the Booth | any | epilogue |  |  |  | R10 retirement epilogue stage |

- **PRO_E01 Retirement Day**: The first morning with nowhere to be. The way it ended decides how it feels. *(Versions by retirement reason (chose / forced out / dismissed).)*
- **PRO_E02 The Phone Call From the Club**: Your last club calls with an offer to stay connected.
- **PRO_E03 Hall of Fame Eligibility**: Five years after your last kick, your name is on the list of eligible players. *(Only if the career earned it (engine formula, request R10).)*
- **PRO_E04 The Nomination**: You're a finalist. *(Hall of Fame earned.)*
- **PRO_E05 The Call**: The call that changes your legacy. *(Hall of Fame earned.)*
- **PRO_E06 The Call That Doesn't Come**: The finalists are announced, and you're not one of them. *(Not earned: a closing scene about what you built anyway.)*
- **PRO_E07 The Speech of a Lifetime**: You write your induction speech and think about everyone who got you there. *(Versions keyed to family and wrong-path flags.)*
- **PRO_E08 The Speech, Second Draft**: You read the speech to {love_interest} and cross out half of it. *(Partner version.)*
- **PRO_E09 The Look Back**: A closing look at the whole career, from the first kick in the backyard. *(Closing summary scene.)*
- **PRO_E10 The Kid With Your Number**: Years later, a kid at a youth camp wears your number and doesn't know who you are.
- **PRO_E11 Coach, Now**: Your first season coaching. The kickers call you 'Coach' and you keep looking behind you. *(If you took a coaching path.)*
- **PRO_E12 In the Booth**: Your first broadcast. Your old club is playing. *(If you took a broadcasting path.)*

