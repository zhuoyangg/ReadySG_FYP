-- ============================================================
-- ReadySG Seed Data v3 — Content Overhaul
--
-- PREREQUISITE: Run schema_migration.sql first.
--
-- Structure:
--   Part A: Cleanup (idempotent)
--   Part B: Courses (5 courses)
--   Part C: Lessons (23 lessons, 4-5 per course)
--   Part D: Quizzes (115 questions, 5 per lesson)
--
-- Safe to re-run: cleanup + fresh insert.
-- ============================================================


-- ═══════════════════════════════════════════════════════════
-- PART A: Cleanup
-- ═══════════════════════════════════════════════════════════

DELETE FROM quizzes;
DELETE FROM lessons;
DELETE FROM courses;


-- ═══════════════════════════════════════════════════════════
-- PART B: Courses (5 courses)
-- ═══════════════════════════════════════════════════════════

INSERT INTO courses (title, description, category, difficulty, sort_order, is_published, created_at)
VALUES
(
  'CPR Essentials',
  'Learn how to perform CPR to save lives during cardiac emergencies. Designed for Singapore residents with no prior training.',
  'cpr', 'beginner', 1, true, now()
),
(
  'AED Training',
  'Learn how to locate and use an Automated External Defibrillator (AED) in Singapore. No medical training required.',
  'aed', 'beginner', 2, true, now()
),
(
  'First Aid Essentials',
  'Essential first aid skills for everyday emergencies — choking, bleeding, burns, fractures, and heat injuries in Singapore.',
  'first_aid', 'beginner', 3, true, now()
),
(
  'Fire Safety',
  'Fire prevention, response, and evacuation for Singapore homes and workplaces — including HDB-specific safety.',
  'fire_safety', 'intermediate', 4, true, now()
),
(
  'Emergency Preparedness',
  'Know Singapore''s emergency systems, build a household emergency kit, and prepare your family for any crisis.',
  'emergency_prep', 'beginner', 5, true, now()
);


-- ═══════════════════════════════════════════════════════════
-- PART C: Lessons (23 lessons)
-- ═══════════════════════════════════════════════════════════

-- ─── CPR Essentials: Lesson 1 ───────────────────────────────────────────────
INSERT INTO lessons (course_id, title, description, content, sort_order, points, is_published, created_at)
SELECT c.id,
  'Introduction to CPR',
  'What CPR is, why it matters, and the C-A-B sequence.',
  $json$[
    {
      "type": "text",
      "title": "What is CPR?",
      "body": "CPR (Cardiopulmonary Resuscitation) is a life-saving technique used when someone's heart stops beating or they stop breathing.\n\n• It keeps blood flowing to the brain and organs\n• Anyone can learn CPR — no medical background needed\n• CPR doubles or triples survival chances\n• In Singapore, SCDF encourages all residents to learn CPR"
    },
    {
      "type": "text",
      "title": "Why CPR Matters",
      "body": "Every minute without CPR decreases survival chances by 10%. Quick action can double or triple survival rates.\n\n• Maintains blood flow to vital organs\n• Buys time until professional help arrives\n• Singapore's average ambulance response: 11 minutes\n• Bystander CPR fills that critical gap"
    },
    {
      "type": "image",
      "title": "How CPR Saves Lives",
      "image_url": "assets/images/lessons/cpr_saves_lives.jpg"
    },
    {
      "type": "text",
      "title": "The C-A-B Sequence",
      "body": "CPR follows the C-A-B sequence — Compressions, Airway, Breathing.\n\n• C — Chest compressions: push hard and fast on the chest\n• A — Airway: tilt the head back, lift the chin\n• B — Breathing: give rescue breaths\n• Compressions are the most critical step"
    },
    {
      "type": "tip",
      "title": "Remember C-A-B",
      "body": "Compressions come first because keeping blood flowing is the top priority. Even hands-only CPR (compressions without breaths) is effective and recommended if you're untrained or uncomfortable with rescue breaths.",
      "color": "blue"
    }
  ]$json$::jsonb,
  1, 10, true, now()
FROM courses c WHERE c.title = 'CPR Essentials';

-- ─── CPR Essentials: Lesson 2 ───────────────────────────────────────────────
INSERT INTO lessons (course_id, title, description, content, sort_order, points, is_published, created_at)
SELECT c.id,
  'Recognising Cardiac Arrest',
  'Learn when CPR is needed — recognising the signs and taking immediate action.',
  $json$[
    {
      "type": "text",
      "title": "When is CPR Needed?",
      "body": "CPR is needed when someone is in cardiac arrest — their heart has stopped pumping blood effectively.\n\n• The person is unresponsive (does not respond to tapping/shouting)\n• They are not breathing or only gasping\n• Cardiac arrest can happen to anyone, at any age\n• It is different from a heart attack (heart attack = blocked artery; cardiac arrest = heart stops)"
    },
    {
      "type": "text",
      "title": "Check for Response",
      "body": "Before starting CPR, you must quickly check if the person is responsive.\n\n• Tap both shoulders firmly\n• Shout: \"Are you okay? Can you hear me?\"\n• If no response, shout for help immediately\n• If alone, call 995 on speakerphone before starting CPR"
    },
    {
      "type": "text",
      "title": "Check for Breathing",
      "body": "After confirming unresponsiveness, check for normal breathing. This should take no more than 10 seconds.\n\n• Look at the chest — is it rising and falling?\n• Listen near their mouth for breath sounds\n• Feel for air on your cheek\n• Gasping or gurgling is NOT normal breathing — begin CPR"
    },
    {
      "type": "video",
      "title": "Recognising Cardiac Arrest",
      "youtube_id": "FwL4JfuoCk0"
    },
    {
      "type": "text",
      "title": "Call 995 Immediately",
      "body": "Once you confirm cardiac arrest, call Singapore's emergency number 995 right away.\n\n• Tell the dispatcher: \"Someone is in cardiac arrest\"\n• Give your location clearly (block number, street, landmark)\n• Follow the dispatcher's CPR instructions\n• Ask a bystander to fetch the nearest AED"
    },
    {
      "type": "tip",
      "title": "Don't Hesitate",
      "body": "It's better to start CPR on someone who doesn't need it than to do nothing for someone who does. You cannot make things worse — the person is already in the worst possible state. Act fast.",
      "color": "orange"
    }
  ]$json$::jsonb,
  2, 10, true, now()
FROM courses c WHERE c.title = 'CPR Essentials';

-- ─── CPR Essentials: Lesson 3 ───────────────────────────────────────────────
INSERT INTO lessons (course_id, title, description, content, sort_order, points, is_published, created_at)
SELECT c.id,
  'Chest Compressions',
  'Proper hand position, compression depth, and technique for effective chest compressions.',
  $json$[
    {
      "type": "text",
      "title": "Hand Position",
      "body": "Correct hand placement is essential for effective compressions.\n\n• Place the heel of one hand on the centre of the chest (on the breastbone)\n• Place your other hand on top, interlocking fingers\n• Keep your arms straight — lock your elbows\n• Position your shoulders directly above your hands"
    },
    {
      "type": "image",
      "title": "Correct Hand Position",
      "image_url": "assets/images/lessons/cpr_hand_position.jpg"
    },
    {
      "type": "text",
      "title": "Compression Depth & Technique",
      "body": "Push hard and push fast — compressions need to be deep enough to pump blood.\n\n• Push down at least 5 cm (about 2 inches) deep\n• Allow the chest to fully recoil between compressions\n• Use your body weight, not just your arms\n• Keep compressions smooth and consistent"
    },
    {
      "type": "text",
      "title": "Compression Rate",
      "body": "The ideal rate is 100–120 compressions per minute.\n\n• Think of the beat of \"Stayin' Alive\" by the Bee Gees\n• Count aloud: \"1 and 2 and 3 and 4...\" up to 30\n• Don't pause between compressions\n• If you're getting tired, switch with another rescuer every 2 minutes"
    },
    {
      "type": "video",
      "title": "Chest Compression Demonstration",
      "youtube_id": "2PngCv7NjaI"
    },
    {
      "type": "tip",
      "title": "Push Hard, Push Fast",
      "body": "Many people are afraid of pushing too hard. In reality, it's very rare to push too hard during CPR. Effective compressions require significant force. You may feel or hear a crack — this is normal and not a reason to stop.",
      "color": "green"
    }
  ]$json$::jsonb,
  3, 10, true, now()
FROM courses c WHERE c.title = 'CPR Essentials';

-- ─── CPR Essentials: Lesson 4 ───────────────────────────────────────────────
INSERT INTO lessons (course_id, title, description, content, sort_order, points, is_published, created_at)
SELECT c.id,
  'Rescue Breathing',
  'How to deliver rescue breaths, including the head-tilt chin-lift technique.',
  $json$[
    {
      "type": "text",
      "title": "The 30:2 Ratio",
      "body": "CPR alternates between 30 chest compressions and 2 rescue breaths.\n\n• Perform 30 compressions at 100–120 per minute\n• Then give 2 rescue breaths (1 second each)\n• Each breath should make the chest visibly rise\n• Continue the cycle until help arrives or the person recovers"
    },
    {
      "type": "text",
      "title": "Head-Tilt Chin-Lift",
      "body": "Before giving breaths, you must open the airway.\n\n• Place one hand on the forehead\n• Use two fingers under the bony part of the chin\n• Gently tilt the head back and lift the chin\n• This moves the tongue away from the airway"
    },
    {
      "type": "image",
      "title": "Head-Tilt Chin-Lift Position",
      "image_url": "assets/images/lessons/cpr_airway.jpg"
    },
    {
      "type": "text",
      "title": "Giving Rescue Breaths",
      "body": "Deliver breaths effectively to oxygenate the blood.\n\n• Pinch the nose shut\n• Create a seal over the person's mouth with yours\n• Blow steadily for about 1 second\n• Watch for the chest to rise — if it doesn't, reposition the head and try again"
    },
    {
      "type": "tip",
      "title": "Hands-Only CPR is OK",
      "body": "If you're uncomfortable giving rescue breaths or don't have a barrier device, hands-only CPR (continuous compressions without breaths) is still highly effective. It's far better than doing nothing. The Singapore Resuscitation Council supports hands-only CPR for untrained bystanders.",
      "color": "blue"
    }
  ]$json$::jsonb,
  4, 10, true, now()
FROM courses c WHERE c.title = 'CPR Essentials';

-- ─── CPR Essentials: Lesson 5 ───────────────────────────────────────────────
INSERT INTO lessons (course_id, title, description, content, sort_order, points, is_published, created_at)
SELECT c.id,
  'CPR for Children & Infants',
  'Key differences when performing CPR on children (ages 1-8) and infants (under 1 year).',
  $json$[
    {
      "type": "text",
      "title": "Why It Differs",
      "body": "Children and infants are not small adults — CPR technique must be adjusted.\n\n• Children's cardiac arrest is usually caused by breathing problems (not heart problems)\n• Give 2 initial rescue breaths before compressions\n• Use less force for compressions\n• The basic C-A-B sequence still applies"
    },
    {
      "type": "text",
      "title": "Child CPR (Ages 1-8)",
      "body": "For children aged 1 to 8, use a modified technique.\n\n• Use ONE hand for compressions (heel of hand on breastbone)\n• Push down about 5 cm (one-third of chest depth)\n• Compression rate: 100–120 per minute (same as adults)\n• Ratio: 30 compressions to 2 breaths\n• Give gentler rescue breaths"
    },
    {
      "type": "text",
      "title": "Infant CPR (Under 1 Year)",
      "body": "Infant CPR requires special care and gentleness.\n\n• Use TWO FINGERS (index + middle) on the breastbone, just below the nipple line\n• Push down about 4 cm (one-third of chest depth)\n• Cover both the infant's mouth AND nose for rescue breaths\n• Use gentle puffs — not full breaths\n• Ratio: 30 compressions to 2 breaths"
    },
    {
      "type": "video",
      "title": "Child & Infant CPR Demonstration",
      "youtube_id": "MEaPefB1GIM"
    },
    {
      "type": "tip",
      "title": "Start with Breaths for Children",
      "body": "Unlike adult CPR, for children and infants you should give 2 rescue breaths BEFORE starting compressions. This is because paediatric cardiac arrest is usually caused by breathing failure, so restoring oxygen is the first priority.",
      "color": "orange"
    }
  ]$json$::jsonb,
  5, 10, true, now()
FROM courses c WHERE c.title = 'CPR Essentials';


-- ─── AED Training: Lesson 1 ────────────────────────────────────────────────
INSERT INTO lessons (course_id, title, description, content, sort_order, points, is_published, created_at)
SELECT c.id,
  'What is an AED?',
  'How an AED works and why it is essential for cardiac emergencies.',
  $json$[
    {
      "type": "text",
      "title": "Understanding AEDs",
      "body": "An AED (Automated External Defibrillator) is a portable device that delivers an electric shock to restart a heart in cardiac arrest.\n\n• It analyses the heart's rhythm automatically\n• It only delivers a shock if needed — you cannot shock someone accidentally\n• AEDs are designed for use by anyone, even without training\n• Voice prompts guide you through every step"
    },
    {
      "type": "text",
      "title": "Why AEDs Save Lives",
      "body": "An AED combined with CPR dramatically increases survival.\n\n• Defibrillation within 3–5 minutes can raise survival rates to 50–70%\n• CPR alone keeps blood flowing but cannot restart the heart\n• Singapore has over 10,000 AEDs installed island-wide\n• The myResponder app shows AED locations near you"
    },
    {
      "type": "text",
      "title": "Parts of an AED",
      "body": "Every AED has the same basic components you should recognise.\n\n• Power button — turns on the device (some activate when opened)\n• Electrode pads — two sticky pads with cables that attach to the chest\n• Voice/visual prompts — guides you through each step\n• Shock button — clearly marked, you press it when instructed\n• Most AEDs also include a razor, towel, and scissors in the kit"
    },
    {
      "type": "text",
      "title": "AED Safety",
      "body": "AEDs are extremely safe — they are designed to prevent misuse.\n\n• The device analyses the heart rhythm before any shock\n• If no shock is needed, the AED will NOT deliver one\n• You cannot hurt someone by using an AED\n• Singapore's Good Samaritan laws protect you when helping"
    },
    {
      "type": "tip",
      "title": "You Can't Get It Wrong",
      "body": "AEDs are designed for untrained bystanders. The machine tells you exactly what to do through clear voice prompts. Don't be afraid to use one — the only mistake is not trying.",
      "color": "green"
    }
  ]$json$::jsonb,
  1, 10, true, now()
FROM courses c WHERE c.title = 'AED Training';

-- ─── AED Training: Lesson 2 ────────────────────────────────────────────────
INSERT INTO lessons (course_id, title, description, content, sort_order, points, is_published, created_at)
SELECT c.id,
  'Finding AEDs in Singapore',
  'Where AEDs are located across Singapore and how to find one fast.',
  $json$[
    {
      "type": "text",
      "title": "AED Locations in Singapore",
      "body": "Singapore has one of the highest AED densities in Asia. Know where to look.\n\n• MRT stations — every station has at least one AED\n• Shopping malls — usually near information counters or security\n• HDB void decks — many blocks have AEDs in glass cabinets\n• Schools, community centres, sports facilities\n• Office buildings — typically at reception or security desks"
    },
    {
      "type": "text",
      "title": "Using the myResponder App",
      "body": "The SCDF myResponder app is the fastest way to locate the nearest AED.\n\n• Download free from App Store or Google Play\n• Shows all registered AED locations on a map\n• Gives walking directions to the nearest AED\n• Also alerts nearby CPR-trained volunteers during emergencies\n• Available 24/7"
    },
    {
      "type": "image",
      "title": "myResponder App Screenshot",
      "image_url": "assets/images/lessons/aed_myresponder.jpg"
    },
    {
      "type": "image",
      "title": "What AED Cabinets Look Like",
      "image_url": "assets/images/lessons/aed_cabinet.jpg"
    },
    {
      "type": "tip",
      "title": "Download myResponder Now",
      "body": "Don't wait for an emergency. Download the SCDF myResponder app today and check where AEDs are near your home, workplace, and your children's school. Knowing the location in advance saves precious minutes.",
      "color": "blue"
    }
  ]$json$::jsonb,
  2, 10, true, now()
FROM courses c WHERE c.title = 'AED Training';

-- ─── AED Training: Lesson 3 ────────────────────────────────────────────────
INSERT INTO lessons (course_id, title, description, content, sort_order, points, is_published, created_at)
SELECT c.id,
  'Using an AED Step-by-Step',
  'How to operate an AED from powering on to delivering a shock.',
  $json$[
    {
      "type": "text",
      "title": "Step 1: Power On",
      "body": "As soon as the AED arrives, turn it on immediately.\n\n• Press the power button or open the lid (some turn on automatically)\n• Listen carefully to the voice prompts\n• Continue CPR while someone else prepares the AED\n• If you're alone, stop CPR briefly to set up the AED"
    },
    {
      "type": "text",
      "title": "Step 2: Attach the Pads",
      "body": "Expose the chest and attach the electrode pads as shown on the diagram.\n\n• Remove clothing from the chest (cut if necessary)\n• Peel the backing off each pad\n• Place one pad on the upper right chest (below the collarbone)\n• Place the other pad on the lower left side (below the armpit)\n• Press firmly to ensure good contact"
    },
    {
      "type": "image",
      "title": "AED Pad Placement",
      "image_url": "assets/images/lessons/aed_pad_placement.jpg"
    },
    {
      "type": "text",
      "title": "Step 3: Analyse & Shock",
      "body": "Let the AED analyse the heart rhythm and follow its instructions.\n\n• The AED will say \"Analysing rhythm — do not touch the patient\"\n• Make sure nobody is touching the person\n• If a shock is advised, the AED will say \"Shock advised — press the shock button\"\n• Shout \"CLEAR!\" and press the shock button\n• If no shock is advised, resume CPR immediately"
    },
    {
      "type": "video",
      "title": "AED Demonstration",
      "youtube_id": "4e-Zqs31K1s",
      "start_seconds": 126
    },
    {
      "type": "tip",
      "title": "Keep Going After the Shock",
      "body": "After delivering a shock, immediately resume CPR (30 compressions, 2 breaths). The AED will re-analyse every 2 minutes. Do not remove the pads. Continue until paramedics arrive or the person starts breathing normally.",
      "color": "orange"
    }
  ]$json$::jsonb,
  3, 10, true, now()
FROM courses c WHERE c.title = 'AED Training';

-- ─── AED Training: Lesson 4 ────────────────────────────────────────────────
INSERT INTO lessons (course_id, title, description, content, sort_order, points, is_published, created_at)
SELECT c.id,
  'AED Special Situations',
  'Handling wet surfaces, children, pacemakers, and other special circumstances.',
  $json$[
    {
      "type": "text",
      "title": "Wet Surfaces & Sweat",
      "body": "Water conducts electricity — you need a dry surface for AED use.\n\n• Move the person to a dry area if possible\n• Quickly dry the chest before applying pads\n• Do NOT use an AED in standing water\n• A damp floor is okay as long as the chest is dry\n• Singapore's rain and humidity make this especially important"
    },
    {
      "type": "text",
      "title": "Pacemakers & Medication Patches",
      "body": "Some people have implanted devices or patches on their chest.\n\n• Look for a hard lump under the skin (pacemaker/defibrillator)\n• Place AED pads at least 2.5 cm away from the device\n• Remove any medication patches (e.g., nicotine, pain relief) from the chest\n• Wipe the area before placing pads\n• Don't delay — adjust pad placement and proceed"
    },
    {
      "type": "text",
      "title": "Children & Infants",
      "body": "AEDs can be used on children with some adjustments.\n\n• Use paediatric pads if available (lower energy dose)\n• If no paediatric pads, use adult pads\n• For small children: place one pad on the chest, one on the back\n• Never let the pads touch each other\n• An AED is always better than no AED, regardless of pad type"
    },
    {
      "type": "text",
      "title": "Excessive Chest Hair",
      "body": "Chest hair can prevent good pad contact.\n\n• If pads don't stick, press down firmly\n• If still not sticking, quickly shave the area (many AED kits include a razor)\n• Alternatively, apply pads, rip them off to remove hair, then apply new pads\n• Don't spend too long on this — speed matters"
    },
    {
      "type": "tip",
      "title": "When NOT to Use an AED",
      "body": "Do NOT use an AED: in standing water, near flammable gases, or on a moving vehicle. If the person is conscious and breathing normally, they do not need an AED. If in doubt, turn on the AED — it will tell you if a shock is needed.",
      "color": "red"
    }
  ]$json$::jsonb,
  4, 10, true, now()
FROM courses c WHERE c.title = 'AED Training';


-- ─── First Aid Essentials: Lesson 1 ────────────────────────────────────────
INSERT INTO lessons (course_id, title, description, content, sort_order, points, is_published, created_at)
SELECT c.id,
  'Responding to Choking',
  'How to recognise and respond to choking in adults, children, and infants.',
  $json$[
    {
      "type": "text",
      "title": "Recognising Choking",
      "body": "Choking occurs when an object blocks the airway, preventing breathing.\n\n• The person clutches their throat (universal choking sign)\n• Unable to speak, cough, or breathe\n• Face turns red, then blue\n• May make high-pitched squeaking sounds\n• Common causes: food (especially fishballs, grapes, nuts), small objects"
    },
    {
      "type": "text",
      "title": "Mild vs Severe Choking",
      "body": "The response depends on whether the person can still cough.\n\n• Mild choking: person can cough, speak, or breathe — encourage forceful coughing\n• Severe choking: person cannot speak, cough, or breathe — act immediately\n• Do NOT slap the back of someone who can still cough\n• Ask: \"Are you choking? Can you cough?\""
    },
    {
      "type": "text",
      "title": "Back Blows & Abdominal Thrusts",
      "body": "For severe choking in adults and children over 1 year.\n\n• Give 5 sharp back blows between the shoulder blades (with heel of hand)\n• If unsuccessful, give 5 abdominal thrusts (Heimlich manoeuvre)\n• Stand behind the person, make a fist above the navel\n• Pull sharply inwards and upwards\n• Alternate: 5 back blows, then 5 thrusts until cleared"
    },
    {
      "type": "video",
      "title": "Choking Response Demonstration",
      "youtube_id": "o5jX54TJ2UE"
    },
    {
      "type": "text",
      "title": "Infant Choking (Under 1 Year)",
      "body": "Infant choking requires a different technique — never use abdominal thrusts.\n\n• Lay the infant face-down on your forearm, supporting the head\n• Give 5 back blows between the shoulder blades\n• Turn the infant face-up and give 5 chest thrusts (2 fingers on breastbone)\n• Alternate until the object is cleared\n• If the infant becomes unconscious, call 995 and start CPR"
    },
    {
      "type": "tip",
      "title": "Call 995 If It Doesn't Clear",
      "body": "If back blows and thrusts don't clear the airway within a few cycles, call 995 immediately. If the person becomes unconscious, lower them to the ground and begin CPR — compressions may dislodge the object.",
      "color": "orange"
    }
  ]$json$::jsonb,
  1, 10, true, now()
FROM courses c WHERE c.title = 'First Aid Essentials';

-- ─── First Aid Essentials: Lesson 2 ────────────────────────────────────────
INSERT INTO lessons (course_id, title, description, content, sort_order, points, is_published, created_at)
SELECT c.id,
  'Controlling Bleeding',
  'How to manage minor cuts and severe bleeding emergencies.',
  $json$[
    {
      "type": "text",
      "title": "Assessing Bleeding",
      "body": "Not all bleeding is the same — severity determines your response.\n\n• Minor bleeding: small cuts, grazes — clean and bandage\n• Severe bleeding: blood spurting or flowing steadily — life-threatening\n• A person can bleed to death in under 5 minutes from a major wound\n• Protect yourself: wear gloves if available, or use a plastic bag"
    },
    {
      "type": "text",
      "title": "Direct Pressure",
      "body": "For severe bleeding, apply firm direct pressure immediately.\n\n• Press a clean cloth, towel, or clothing firmly on the wound\n• Use both hands if needed — push hard\n• Do NOT remove the cloth if it soaks through — add more on top\n• Maintain pressure continuously for at least 10 minutes\n• If possible, raise the injured limb above the heart"
    },
    {
      "type": "image",
      "title": "Applying Direct Pressure",
      "image_url": "assets/images/lessons/first_aid_direct_pressure.jpg"
    },
    {
      "type": "text",
      "title": "When to Call 995",
      "body": "Call 995 for severe bleeding that doesn't stop.\n\n• Blood is spurting or won't stop after 10 minutes of pressure\n• The wound is deep or caused by a sharp object\n• An object is embedded in the wound (do NOT remove it)\n• The person feels faint, dizzy, or confused (signs of shock)\n• Any wound that exposes bone, muscle, or fat"
    },
    {
      "type": "tip",
      "title": "Never Remove Embedded Objects",
      "body": "If a knife, glass, or other object is stuck in a wound, do NOT pull it out. Removing it can cause more bleeding. Instead, apply pressure around the object and bandage to keep it stable. Let paramedics handle removal.",
      "color": "red"
    }
  ]$json$::jsonb,
  2, 10, true, now()
FROM courses c WHERE c.title = 'First Aid Essentials';

-- ─── First Aid Essentials: Lesson 3 ────────────────────────────────────────
INSERT INTO lessons (course_id, title, description, content, sort_order, points, is_published, created_at)
SELECT c.id,
  'Treating Burns',
  'First aid for thermal, chemical, and electrical burns.',
  $json$[
    {
      "type": "text",
      "title": "Types of Burns",
      "body": "Burns can be caused by heat, chemicals, electricity, or the sun.\n\n• Thermal burns: hot liquids (most common in Singapore kitchens), flames, hot surfaces\n• Chemical burns: cleaning products, industrial chemicals\n• Electrical burns: faulty wiring, lightning\n• The severity depends on depth and area affected\n• Even \"minor\" burns can be serious on the face, hands, or joints"
    },
    {
      "type": "text",
      "title": "Cool the Burn",
      "body": "Cooling is the most important first aid for burns.\n\n• Run cool (not ice-cold) running water over the burn for 20 minutes\n• Do this as soon as possible — even hours later it still helps\n• Do NOT use ice, butter, toothpaste, or soy sauce (common myths)\n• Remove jewellery and loose clothing near the burn before swelling\n• Cover with cling film or a clean, non-fluffy cloth after cooling"
    },
    {
      "type": "text",
      "title": "When to Call 995",
      "body": "Some burns require immediate emergency care.\n\n• Burns larger than the person's palm\n• Burns on the face, neck, hands, feet, or groin\n• Burns that go all the way around a limb\n• Chemical or electrical burns\n• Burns on children under 5 or elderly\n• Any burn with white, brown, or charred skin (deep burn)"
    },
    {
      "type": "text",
      "title": "Burn First Aid Steps",
      "body": "Follow these four steps for any burn.\n\n• Cool — Run cool water over the burn for 20 minutes\n• Remove — Take off jewellery and loose clothing near the burn\n• Cover — Apply cling film or a clean, non-fluffy cloth\n• Call 995 — If the burn is larger than a palm, on sensitive areas, or caused by chemicals/electricity"
    },
    {
      "type": "tip",
      "title": "20 Minutes of Cool Water",
      "body": "The most common mistake is not cooling long enough. Set a timer for 20 minutes. Cool running water reduces pain, limits damage, and speeds healing. Never use ice — it can cause frostbite on damaged skin.",
      "color": "green"
    }
  ]$json$::jsonb,
  3, 10, true, now()
FROM courses c WHERE c.title = 'First Aid Essentials';

-- ─── First Aid Essentials: Lesson 4 ────────────────────────────────────────
INSERT INTO lessons (course_id, title, description, content, sort_order, points, is_published, created_at)
SELECT c.id,
  'Fractures & Sprains',
  'Recognising and managing broken bones and sprains using the RICE method.',
  $json$[
    {
      "type": "text",
      "title": "Recognising a Fracture",
      "body": "A fracture is a broken bone — it may not always be obvious.\n\n• Intense pain that worsens with movement\n• Swelling, bruising, or deformity\n• Inability to move or bear weight on the limb\n• A grinding or cracking sound at the time of injury\n• Numbness or tingling below the injury"
    },
    {
      "type": "text",
      "title": "Immobilise — Don't Realign",
      "body": "Never try to straighten a broken bone. Keep it still.\n\n• Support the limb in the position you find it\n• Use padding (towels, pillows, clothing) to prevent movement\n• If a splint is needed, secure above and below the break\n• Apply an ice pack wrapped in cloth to reduce swelling\n• Call 995 for open fractures, suspected spinal injuries, or hip/thigh fractures"
    },
    {
      "type": "text",
      "title": "Sprains: The RICE Method",
      "body": "Sprains are stretched or torn ligaments — common in sports.\n\n• R — Rest: stop using the injured area\n• I — Ice: apply for 20 minutes every 2 hours (wrap ice in cloth)\n• C — Compression: wrap with an elastic bandage (not too tight)\n• E — Elevation: raise the injured area above heart level\n• See a doctor if you can't bear weight or swelling doesn't improve in 48 hours"
    },
    {
      "type": "image",
      "title": "RICE Method Illustration",
      "image_url": "assets/images/lessons/first_aid_rice.jpg"
    },
    {
      "type": "tip",
      "title": "When to Call 995",
      "body": "Call 995 immediately if: bone is visible through the skin (open fracture), the person cannot move or feel the limb, a head/neck/spine injury is suspected, or the person is in severe shock. Do NOT move someone with a suspected spinal injury.",
      "color": "red"
    }
  ]$json$::jsonb,
  4, 10, true, now()
FROM courses c WHERE c.title = 'First Aid Essentials';

-- ─── First Aid Essentials: Lesson 5 ────────────────────────────────────────
INSERT INTO lessons (course_id, title, description, content, sort_order, points, is_published, created_at)
SELECT c.id,
  'Heat Injuries in Singapore',
  'Recognising and treating heat exhaustion and heatstroke — critical in Singapore''s tropical climate.',
  $json$[
    {
      "type": "text",
      "title": "Why Singapore is High-Risk",
      "body": "Singapore's tropical climate makes heat injuries a real danger.\n\n• Average temperature: 31°C with high humidity (often 80%+)\n• Humidity prevents sweat from evaporating, trapping body heat\n• Outdoor workers, NS personnel, and athletes are most at risk\n• Even everyday activities (walking, waiting for buses) can cause heat stress\n• NEA issues heat stress advisories during extreme weather"
    },
    {
      "type": "text",
      "title": "Heat Exhaustion",
      "body": "Heat exhaustion is a warning sign — the body is overheating.\n\n• Heavy sweating, cold and clammy skin\n• Weakness, dizziness, nausea\n• Headache, muscle cramps\n• Fast but weak pulse\n• Treatment: move to cool area, loosen clothing, sip water, apply cool cloths\n• If untreated, it can progress to heatstroke"
    },
    {
      "type": "text",
      "title": "Heatstroke — A Medical Emergency",
      "body": "Heatstroke is life-threatening. The body's cooling system has failed.\n\n• Body temperature above 40°C\n• Hot, red, DRY skin (sweating has stopped)\n• Confusion, slurred speech, loss of consciousness\n• Rapid, strong pulse\n• Call 995 immediately\n• Cool the person rapidly: ice packs on neck, armpits, groin"
    },
    {
      "type": "image",
      "title": "Heat Exhaustion vs Heatstroke",
      "image_url": "assets/images/lessons/first_aid_heat.jpg"
    },
    {
      "type": "text",
      "title": "Prevention",
      "body": "Simple steps to stay safe in Singapore's heat.\n\n• Drink water regularly — at least 500 ml per hour during outdoor activity\n• Wear light, loose, light-coloured clothing\n• Avoid strenuous activity between 10 am and 4 pm\n• Take regular breaks in shade or air-conditioned spaces\n• Never leave children or pets in parked cars"
    },
    {
      "type": "tip",
      "title": "Heatstroke = Call 995",
      "body": "The key difference: heat exhaustion — person is still sweating. Heatstroke — sweating has STOPPED and skin is hot and dry. Heatstroke is always a 995 emergency. Cool the person aggressively while waiting for the ambulance.",
      "color": "orange"
    }
  ]$json$::jsonb,
  5, 10, true, now()
FROM courses c WHERE c.title = 'First Aid Essentials';


-- ─── Fire Safety: Lesson 1 ──────────────────────────────────────────────────
INSERT INTO lessons (course_id, title, description, content, sort_order, points, is_published, created_at)
SELECT c.id,
  'Fire Hazards in Singapore',
  'Common causes of fires in Singapore homes and how to prevent them.',
  $json$[
    {
      "type": "text",
      "title": "Common Fire Causes",
      "body": "Understanding fire hazards helps you prevent them.\n\n• Unattended cooking — the #1 cause of residential fires in Singapore\n• Electrical faults — overloaded power sockets, damaged wiring\n• Discarded smoking materials — lit cigarettes in rubbish chutes\n• PMD/e-scooter battery fires — overcharging, damaged batteries\n• Joss paper burning — during Hungry Ghost Festival and Qing Ming"
    },
    {
      "type": "text",
      "title": "Kitchen Fire Safety",
      "body": "Most Singapore home fires start in the kitchen.\n\n• Never leave cooking unattended, especially deep frying\n• Keep flammable items away from the stove\n• Turn off the gas supply when not cooking\n• Clean grease buildup from the stove and hood regularly\n• If a pot catches fire, cover it with a lid — never use water on an oil fire"
    },
    {
      "type": "text",
      "title": "Electrical Safety",
      "body": "Faulty electrics cause about 30% of fires in Singapore.\n\n• Don't overload power sockets — use one plug per socket\n• Replace damaged or frayed cords immediately\n• Switch off appliances at the socket when not in use\n• Don't run cables under rugs or through door frames\n• Hire a licensed electrician for any electrical work"
    },
    {
      "type": "text",
      "title": "PMD & E-Scooter Safety",
      "body": "Personal Mobility Device fires have become a growing concern in Singapore.\n\n• Never charge PMD batteries overnight or unattended\n• Use only the original charger that came with the device\n• Do not charge near flammable materials or exits\n• If the battery is swollen, damaged, or smells unusual, stop using it immediately\n• Dispose of damaged batteries at proper e-waste collection points"
    },
    {
      "type": "tip",
      "title": "PMD Battery Fires",
      "body": "PMD and e-scooter fires have increased sharply in Singapore. Never charge batteries overnight or unattended. Use only the original charger. If the battery is swollen, damaged, or smells unusual, stop using it immediately and bring it to a proper disposal point.",
      "color": "red"
    }
  ]$json$::jsonb,
  1, 10, true, now()
FROM courses c WHERE c.title = 'Fire Safety';

-- ─── Fire Safety: Lesson 2 ──────────────────────────────────────────────────
INSERT INTO lessons (course_id, title, description, content, sort_order, points, is_published, created_at)
SELECT c.id,
  'Using a Fire Extinguisher',
  'The PASS technique and when to use a fire extinguisher.',
  $json$[
    {
      "type": "text",
      "title": "When to Use an Extinguisher",
      "body": "Fire extinguishers are for small fires only — know your limits.\n\n• Only fight a fire if it's small (e.g., wastebasket-sized)\n• You have a clear escape route behind you\n• You have the right type of extinguisher\n• The room is not filled with smoke\n• If in doubt, evacuate immediately — your life is more important"
    },
    {
      "type": "text",
      "title": "The PASS Technique",
      "body": "Remember PASS to operate any fire extinguisher.\n\n• P — Pull the safety pin\n• A — Aim the nozzle at the BASE of the fire (not the flames)\n• S — Squeeze the handle firmly\n• S — Sweep from side to side at the base\n• Stand 1.5–2 metres away from the fire"
    },
    {
      "type": "video",
      "title": "PASS Technique Demonstration",
      "youtube_id": "tV37SBlsrhI"
    },
    {
      "type": "text",
      "title": "Types of Extinguishers",
      "body": "Different fires need different extinguishers.\n\n• ABC Dry Powder (red with blue label) — most common, works on most fires\n• CO2 (red with black label) — for electrical and flammable liquid fires\n• Water (all red) — for paper, wood, fabric fires only\n• The ABC dry powder extinguisher is the best all-round choice for homes\n• Most HDB common areas have ABC dry powder extinguishers"
    },
    {
      "type": "tip",
      "title": "Aim at the BASE",
      "body": "The most common mistake is aiming at the flames. Always aim at the BASE of the fire where the fuel is burning. Sweep side to side until the fire is out. If it reignites or doesn't go out, evacuate immediately.",
      "color": "green"
    }
  ]$json$::jsonb,
  2, 10, true, now()
FROM courses c WHERE c.title = 'Fire Safety';

-- ─── Fire Safety: Lesson 3 ──────────────────────────────────────────────────
INSERT INTO lessons (course_id, title, description, content, sort_order, points, is_published, created_at)
SELECT c.id,
  'HDB & High-Rise Evacuation',
  'How to evacuate safely from HDB flats, condos, and high-rise buildings.',
  $json$[
    {
      "type": "text",
      "title": "Plan Your Escape Route",
      "body": "Every HDB household should have an evacuation plan.\n\n• Know TWO ways out of your flat (main door + service yard/balcony)\n• Identify the nearest staircase (not the lift!)\n• Practice the route with your family, including children and elderly\n• Keep corridors and escape routes clear of shoes, bicycles, potted plants\n• Keep your keys near the door — don't fumble in an emergency"
    },
    {
      "type": "text",
      "title": "When You Discover a Fire",
      "body": "Follow the RACE protocol — Rescue, Alarm, Contain, Evacuate.\n\n• R — Rescue anyone in immediate danger (if safe to do so)\n• A — Alarm: shout \"FIRE!\" and activate the fire alarm if available\n• C — Contain: close all doors behind you to slow the fire\n• E — Evacuate: leave via the staircase, NOT the lift\n• Call 995 once you are safely outside"
    },
    {
      "type": "text",
      "title": "Evacuating from High-Rise",
      "body": "Special considerations for HDB flats and condos.\n\n• Always use staircases — lifts may stop or fill with smoke\n• Stay low if there is smoke — crawl if necessary\n• Feel doors before opening — if hot, use another route\n• Close doors behind you to slow fire and smoke spread\n• Go DOWN to the ground floor; go UP only if the fire is below you"
    },
    {
      "type": "text",
      "title": "What to Do in Common Areas",
      "body": "Singapore HDB blocks have specific features to know about.\n\n• Staircase locations vary — familiarise yourself with ALL staircases on your floor\n• Refuse chutes can spread fire between floors — keep chute doors closed\n• Corridor clutter (shoes, bikes, boxes) blocks evacuation — keep corridors clear\n• Fire hose reels are on every floor of most HDB blocks — learn to use them\n• Assembly areas are usually at open spaces near the void deck"
    },
    {
      "type": "text",
      "title": "If You Are Trapped",
      "body": "Sometimes the safest option is to stay and wait for SCDF.\n\n• Close all doors between you and the fire\n• Seal gaps under doors with wet towels or clothing\n• Move to a room with a window\n• Signal for help: wave a bright cloth, use your phone torch\n• Call 995 and tell them your exact unit number and floor\n• Do NOT jump — SCDF will reach you"
    },
    {
      "type": "tip",
      "title": "Close Your Doors",
      "body": "A closed door can hold back fire and smoke for up to 30 minutes. Always sleep with your bedroom door closed. When evacuating, close every door behind you — it could save your neighbour's life.",
      "color": "orange"
    }
  ]$json$::jsonb,
  3, 10, true, now()
FROM courses c WHERE c.title = 'Fire Safety';

-- ─── Fire Safety: Lesson 4 ──────────────────────────────────────────────────
INSERT INTO lessons (course_id, title, description, content, sort_order, points, is_published, created_at)
SELECT c.id,
  'Smoke Inhalation & Burns',
  'Why smoke kills faster than fire and basic burn first aid.',
  $json$[
    {
      "type": "text",
      "title": "Smoke Kills Faster Than Fire",
      "body": "Most fire deaths are caused by smoke inhalation, not burns.\n\n• Smoke contains toxic gases (carbon monoxide, hydrogen cyanide)\n• Just 2–3 breaths of toxic smoke can make you unconscious\n• Smoke rises — breathable air is near the floor\n• In a smoky room, crawl on your hands and knees\n• Cover your nose and mouth with a wet cloth if possible"
    },
    {
      "type": "text",
      "title": "Smoke Detectors Save Lives",
      "body": "A working smoke detector gives you early warning — usually 3–5 minutes.\n\n• Install at least one on every level of your home\n• Place them on the ceiling, away from kitchens and bathrooms\n• Test the alarm monthly by pressing the test button\n• Replace batteries yearly (or when it chirps)\n• SCDF provides free smoke detectors for some HDB households"
    },
    {
      "type": "text",
      "title": "Where to Install Smoke Detectors",
      "body": "Proper placement makes the difference between early warning and no warning.\n\n• Install on the ceiling, at least 30 cm from any wall\n• Place in every bedroom and the living room\n• Avoid kitchens and bathrooms (cooking steam and humidity cause false alarms)\n• Test monthly by pressing the test button\n• Replace batteries yearly, or when it starts chirping"
    },
    {
      "type": "text",
      "title": "First Aid for Burns",
      "body": "Quick action reduces burn severity.\n\n• Cool the burn under running water for 20 minutes\n• Remove rings, watches, clothing near the burn (before swelling)\n• Cover with cling film or a clean cloth\n• Do NOT apply ice, butter, toothpaste, or traditional remedies\n• Call 995 for burns larger than the person's palm"
    },
    {
      "type": "tip",
      "title": "Install a Smoke Detector Today",
      "body": "A $15 smoke detector is the single best investment for your family's fire safety. SCDF has distributed free detectors to HDB households — check if you're eligible at the SCDF website.",
      "color": "blue"
    }
  ]$json$::jsonb,
  4, 10, true, now()
FROM courses c WHERE c.title = 'Fire Safety';


-- ─── Emergency Preparedness: Lesson 1 ──────────────────────────────────────
INSERT INTO lessons (course_id, title, description, content, sort_order, points, is_published, created_at)
SELECT c.id,
  'Singapore Emergency Numbers',
  'Know which number to call for different emergencies in Singapore.',
  $json$[
    {
      "type": "text",
      "title": "The Numbers You Must Know",
      "body": "In Singapore, different emergencies have different numbers.\n\n• 995 — Ambulance and fire (SCDF)\n• 999 — Police\n• 1777 — Non-emergency ambulance\n• 1800-286-5555 — SGSecure hotline (terror threats)\n• 1800-221-4444 — Samaritans of Singapore (crisis support)"
    },
    {
      "type": "text",
      "title": "When to Call 995 vs 999",
      "body": "Knowing which number to call saves time.\n\n• 995 (SCDF): medical emergencies, cardiac arrest, fire, rescue\n• 999 (SPF): crime in progress, accidents with injuries, suspicious activities\n• 1777: non-life-threatening medical transport\n• If unsure, call 995 — they will redirect if needed\n• All three numbers are free from any phone"
    },
    {
      "type": "text",
      "title": "Useful Emergency Apps",
      "body": "Singapore has several apps that help during emergencies.\n\n• myResponder (SCDF): alerts CPR-trained volunteers, shows AED locations\n• SGSecure (MHA): report threats, get emergency alerts\n• Police@SG (SPF): report crimes, find nearest police post\n• OneService (MND): report municipal issues (non-emergency)\n• Download these apps now — don't wait for an emergency"
    },
    {
      "type": "tip",
      "title": "Save These Numbers",
      "body": "Save 995, 999, and 1777 in your phone contacts right now. Teach your children to call 995 in an emergency. Remember: calling 995 or 999 from a locked phone works even without a SIM card.",
      "color": "blue"
    }
  ]$json$::jsonb,
  1, 10, true, now()
FROM courses c WHERE c.title = 'Emergency Preparedness';

-- ─── Emergency Preparedness: Lesson 2 ──────────────────────────────────────
INSERT INTO lessons (course_id, title, description, content, sort_order, points, is_published, created_at)
SELECT c.id,
  'Calling 995 Effectively',
  'What to say when calling SCDF, and how to guide responders to your location.',
  $json$[
    {
      "type": "text",
      "title": "Stay Calm and Speak Clearly",
      "body": "The dispatcher needs key information quickly.\n\n• Take a deep breath before speaking\n• Speak in English (or Mandarin/Malay/Tamil — dispatchers are multilingual)\n• The dispatcher will guide you — follow their instructions\n• Stay on the line until they say you can hang up\n• Put your phone on speaker so you can provide aid while talking"
    },
    {
      "type": "text",
      "title": "The 5 W's",
      "body": "Tell the dispatcher these five things.\n\n• What happened? (\"Someone collapsed and is not breathing\")\n• Where are you? (Block number, street name, unit number, nearest landmark)\n• Who needs help? (Age, gender, number of casualties)\n• When did it happen? (\"About 5 minutes ago\")\n• What have you done so far? (\"I started CPR\")"
    },
    {
      "type": "text",
      "title": "Giving Your Location",
      "body": "In Singapore, be as specific as possible with your location.\n\n• HDB: \"Block 123, Ang Mo Kio Avenue 6, level 8, unit 08-123\"\n• Outdoors: nearest block number, bus stop, or MRT station\n• Mall/building: building name, floor, store name\n• Use SingPost codes if you know them\n• If unsure, share your live location via WhatsApp with someone who can relay it"
    },
    {
      "type": "tip",
      "title": "Send a Runner",
      "body": "If you're with others, send someone to meet the ambulance at the void deck or building entrance. Paramedics lose precious time finding the right block and lift. A person waving them in can save 2–3 minutes.",
      "color": "green"
    }
  ]$json$::jsonb,
  2, 10, true, now()
FROM courses c WHERE c.title = 'Emergency Preparedness';

-- ─── Emergency Preparedness: Lesson 3 ──────────────────────────────────────
INSERT INTO lessons (course_id, title, description, content, sort_order, points, is_published, created_at)
SELECT c.id,
  'Building an Emergency Kit',
  'What every Singapore household should have ready for emergencies.',
  $json$[
    {
      "type": "text",
      "title": "The 72-Hour Principle",
      "body": "Be prepared to be self-sufficient for at least 72 hours.\n\n• After a major disaster, help may take up to 3 days to reach everyone\n• A well-stocked kit gives your family peace of mind\n• Keep the kit in an easy-to-grab bag near the door\n• Check and refresh the kit every 6 months\n• Adapt the kit for your family's specific needs (babies, elderly, medication)"
    },
    {
      "type": "text",
      "title": "Essential Supplies",
      "body": "Your emergency kit should include these basics.\n\n• Water: 3 litres per person per day (minimum 9 litres each)\n• Food: non-perishable items (canned food, energy bars, biscuits)\n• First aid kit: bandages, antiseptic, personal medications\n• Torch with extra batteries (or a hand-crank torch)\n• Portable phone charger (power bank)\n• Whistle (to signal for help)"
    },
    {
      "type": "text",
      "title": "Documents & Communication",
      "body": "Keep important documents accessible.\n\n• Copies of NRIC/passport, insurance policies\n• Emergency contact list (printed, not just on phone)\n• Cash in small denominations (ATMs may not work)\n• USB drive with digital copies of key documents\n• Battery-powered or hand-crank radio"
    },
    {
      "type": "tip",
      "title": "Review Every 6 Months",
      "body": "Set a calendar reminder to check your kit every 6 months. Replace expired food and medication, update emergency contacts, recharge power banks, and check torch batteries. A kit that's not maintained is a kit that won't work.",
      "color": "green"
    }
  ]$json$::jsonb,
  3, 10, true, now()
FROM courses c WHERE c.title = 'Emergency Preparedness';

-- ─── Emergency Preparedness: Lesson 4 ──────────────────────────────────────
INSERT INTO lessons (course_id, title, description, content, sort_order, points, is_published, created_at)
SELECT c.id,
  'Haze, Floods & Severe Weather',
  'Preparing for Singapore''s most common natural hazards — transboundary haze, flash floods, and severe storms.',
  $json$[
    {
      "type": "text",
      "title": "Haze Season",
      "body": "Transboundary haze from land clearing fires affects Singapore regularly.\n\n• Typically occurs between June and October\n• Check PSI readings on NEA's website or the myENV app\n• PSI 101–200 (Unhealthy): reduce prolonged outdoor activity\n• PSI 201–300 (Very Unhealthy): avoid outdoor activity\n• PSI 300+ (Hazardous): stay indoors, close windows, use air purifier"
    },
    {
      "type": "text",
      "title": "Protecting Yourself During Haze",
      "body": "Simple steps to reduce health impact.\n\n• Wear an N95 mask outdoors (surgical masks do NOT filter haze particles)\n• Keep windows and doors closed\n• Use an air purifier with HEPA filter if available\n• Drink plenty of water\n• Those with asthma, heart/lung conditions, elderly, and children should stay indoors\n• Seek medical help if you experience breathing difficulty"
    },
    {
      "type": "text",
      "title": "Flash Floods in Singapore",
      "body": "Despite our drainage system, flash floods still occur.\n\n• Low-lying areas (Bukit Timah, Orchard Road) are most vulnerable\n• Never walk or drive through floodwater — it may be deeper than it looks\n• Move to higher ground if water rises quickly\n• Monitor PUB's flood alerts via the MyWaters app\n• Avoid underground spaces (basements, underpasses) during heavy rain"
    },
    {
      "type": "text",
      "title": "Thunderstorms & Lightning",
      "body": "Singapore is one of the world's lightning hotspots.\n\n• Average 186 lightning days per year\n• If you hear thunder, seek shelter immediately\n• Avoid open fields, trees, metal structures, and water\n• Wait 30 minutes after the last thunder before going outside\n• SCDF responds to lightning strikes — call 995 if someone is hit"
    },
    {
      "type": "tip",
      "title": "Download myENV",
      "body": "The NEA myENV app gives real-time PSI readings, weather forecasts, and rain alerts. It's essential during haze season. Enable push notifications so you're always informed about air quality in your area.",
      "color": "orange"
    }
  ]$json$::jsonb,
  4, 10, true, now()
FROM courses c WHERE c.title = 'Emergency Preparedness';

-- ─── Emergency Preparedness: Lesson 5 ──────────────────────────────────────
INSERT INTO lessons (course_id, title, description, content, sort_order, points, is_published, created_at)
SELECT c.id,
  'Family Emergency Planning',
  'How to create a family emergency plan and ensure everyone knows what to do.',
  $json$[
    {
      "type": "text",
      "title": "Why You Need a Family Plan",
      "body": "When an emergency strikes, there's no time to figure things out.\n\n• Every family member should know the plan BEFORE an emergency\n• Plans should cover: where to meet, who to call, what to grab\n• Practice the plan together at least once a year\n• Adapt for different scenarios: fire, flood, terror attack\n• Include plans for pets"
    },
    {
      "type": "text",
      "title": "Meeting Points & Communication",
      "body": "Agree on where to regroup if separated.\n\n• Primary meeting point: near your home (e.g., void deck, playground)\n• Secondary meeting point: away from home (e.g., relative's house, school)\n• Out-of-town contact: someone outside Singapore who can relay messages\n• Teach children to recite parents' phone numbers\n• Agree on a WhatsApp group for family emergency communication"
    },
    {
      "type": "text",
      "title": "Special Needs & Vulnerable Members",
      "body": "Plan for those who need extra help.\n\n• Elderly family members: know their medications, mobility needs\n• Young children: practice \"what to do if\" scenarios through play\n• Persons with disabilities: ensure evacuation routes are accessible\n• Keep a list of everyone's medications, allergies, and blood types\n• Inform trusted neighbours about vulnerable household members"
    },
    {
      "type": "text",
      "title": "SGSecure & Community Preparedness",
      "body": "Singapore's national approach to emergency readiness.\n\n• SGSecure app: report suspicious activity, receive emergency alerts\n• \"Run, Hide, Tell\" — the response to a terror threat\n• Community Emergency Response Teams (CERT) train residents\n• Total Defence Day (15 Feb) — annual preparedness reminder\n• Sign up for SCDF's Community First Responder programme"
    },
    {
      "type": "tip",
      "title": "Practice Makes Prepared",
      "body": "Hold a \"family fire drill\" once a year. Make it fun — time yourselves getting to the meeting point. Review your emergency kit together. Even a 15-minute practice session dramatically improves your family's response in a real emergency.",
      "color": "blue"
    }
  ]$json$::jsonb,
  5, 10, true, now()
FROM courses c WHERE c.title = 'Emergency Preparedness';


-- ═══════════════════════════════════════════════════════════
-- Reverse lesson order within each course so the previously last lesson
-- becomes the first lesson shown in the app.
UPDATE lessons AS l
SET sort_order = reversed.new_sort_order
FROM (
  VALUES
    ('CPR for Children & Infants', 1),
    ('Rescue Breathing', 2),
    ('Chest Compressions', 3),
    ('Recognising Cardiac Arrest', 4),
    ('Introduction to CPR', 5),
    ('AED Special Situations', 1),
    ('Using an AED Step-by-Step', 2),
    ('Finding AEDs in Singapore', 3),
    ('What is an AED?', 4),
    ('Heat Injuries in Singapore', 1),
    ('Fractures & Sprains', 2),
    ('Treating Burns', 3),
    ('Controlling Bleeding', 4),
    ('Responding to Choking', 5),
    ('Smoke Inhalation & Burns', 1),
    ('HDB & High-Rise Evacuation', 2),
    ('Using a Fire Extinguisher', 3),
    ('Fire Hazards in Singapore', 4),
    ('Family Emergency Planning', 1),
    ('Haze, Floods & Severe Weather', 2),
    ('Building an Emergency Kit', 3),
    ('Calling 995 Effectively', 4),
    ('Singapore Emergency Numbers', 5)
) AS reversed(title, new_sort_order)
WHERE l.title = reversed.title;

-- PART D: Quizzes (115 questions, 5 per lesson)
-- ═══════════════════════════════════════════════════════════

WITH
cpr_l1 AS (SELECT id FROM lessons WHERE title = 'Introduction to CPR' LIMIT 1),
cpr_l2 AS (SELECT id FROM lessons WHERE title = 'Recognising Cardiac Arrest' LIMIT 1),
cpr_l3 AS (SELECT id FROM lessons WHERE title = 'Chest Compressions' LIMIT 1),
cpr_l4 AS (SELECT id FROM lessons WHERE title = 'Rescue Breathing' LIMIT 1),
cpr_l5 AS (SELECT id FROM lessons WHERE title = 'CPR for Children & Infants' LIMIT 1),
aed_l1 AS (SELECT id FROM lessons WHERE title = 'What is an AED?' LIMIT 1),
aed_l2 AS (SELECT id FROM lessons WHERE title = 'Finding AEDs in Singapore' LIMIT 1),
aed_l3 AS (SELECT id FROM lessons WHERE title = 'Using an AED Step-by-Step' LIMIT 1),
aed_l4 AS (SELECT id FROM lessons WHERE title = 'AED Special Situations' LIMIT 1),
fa_l1  AS (SELECT id FROM lessons WHERE title = 'Responding to Choking' LIMIT 1),
fa_l2  AS (SELECT id FROM lessons WHERE title = 'Controlling Bleeding' LIMIT 1),
fa_l3  AS (SELECT id FROM lessons WHERE title = 'Treating Burns' LIMIT 1),
fa_l4  AS (SELECT id FROM lessons WHERE title = 'Fractures & Sprains' LIMIT 1),
fa_l5  AS (SELECT id FROM lessons WHERE title = 'Heat Injuries in Singapore' LIMIT 1),
fs_l1  AS (SELECT id FROM lessons WHERE title = 'Fire Hazards in Singapore' LIMIT 1),
fs_l2  AS (SELECT id FROM lessons WHERE title = 'Using a Fire Extinguisher' LIMIT 1),
fs_l3  AS (SELECT id FROM lessons WHERE title = 'HDB & High-Rise Evacuation' LIMIT 1),
fs_l4  AS (SELECT id FROM lessons WHERE title = 'Smoke Inhalation & Burns' LIMIT 1),
ep_l1  AS (SELECT id FROM lessons WHERE title = 'Singapore Emergency Numbers' LIMIT 1),
ep_l2  AS (SELECT id FROM lessons WHERE title = 'Calling 995 Effectively' LIMIT 1),
ep_l3  AS (SELECT id FROM lessons WHERE title = 'Building an Emergency Kit' LIMIT 1),
ep_l4  AS (SELECT id FROM lessons WHERE title = 'Haze, Floods & Severe Weather' LIMIT 1),
ep_l5  AS (SELECT id FROM lessons WHERE title = 'Family Emergency Planning' LIMIT 1)

INSERT INTO quizzes (id, lesson_id, question, options, correct_answer_index, explanation, sort_order)
VALUES

-- ── CPR L1: Introduction to CPR ─────────────────────────────────────────────
(gen_random_uuid(), (SELECT id FROM cpr_l1),
 'What does CPR stand for?',
 '["Cardiopulmonary Resuscitation","Cardiac Pressure Response","Central Pulse Recovery","Chest Pump Rescue"]'::jsonb,
 0, 'CPR = Cardiopulmonary Resuscitation, a technique combining chest compressions and rescue breaths.', 1),

(gen_random_uuid(), (SELECT id FROM cpr_l1),
 'What is the correct sequence for CPR?',
 '["A-B-C","C-B-A","C-A-B","B-C-A"]'::jsonb,
 2, 'The American Heart Association and Singapore Resuscitation and First Aid Council recommend C-A-B: Compressions, Airway, Breathing.', 2),

(gen_random_uuid(), (SELECT id FROM cpr_l1),
 'By how much does each minute without CPR decrease survival?',
 '["5%","10%","15%","20%"]'::jsonb,
 1, 'Every minute without CPR decreases survival chances by approximately 10%.', 3),

(gen_random_uuid(), (SELECT id FROM cpr_l1),
 'What is Singapore''s average ambulance response time?',
 '["About 11 minutes","About 5 minutes","About 20 minutes","About 30 minutes"]'::jsonb,
 0, 'SCDF''s average emergency response time is about 11 minutes, which is why bystander CPR is critical.', 4),

(gen_random_uuid(), (SELECT id FROM cpr_l1),
 'What is the most critical step in CPR?',
 '["Calling 995","Chest compressions","Rescue breaths","Checking the airway"]'::jsonb,
 1, 'Chest compressions keep blood flowing to vital organs and are the most critical step in CPR.', 5),

-- ── CPR L2: Recognising Cardiac Arrest ──────────────────────────────────────
(gen_random_uuid(), (SELECT id FROM cpr_l2),
 'What is the first thing you should do when you find an unresponsive person?',
 '["Tap their shoulders and shout","Start chest compressions","Call your family","Move them to a bed"]'::jsonb,
 0, 'Always check for responsiveness first by tapping shoulders and shouting before starting CPR.', 1),

(gen_random_uuid(), (SELECT id FROM cpr_l2),
 'How long should you spend checking for breathing?',
 '["5 seconds","No more than 10 seconds","30 seconds","1 minute"]'::jsonb,
 1, 'Spend no more than 10 seconds checking for breathing — every second counts in cardiac arrest.', 2),

(gen_random_uuid(), (SELECT id FROM cpr_l2),
 'What is Singapore''s emergency number for ambulance and fire?',
 '["995","999","911","112"]'::jsonb,
 0, '995 is Singapore''s SCDF emergency number for ambulance and fire services.', 3),

(gen_random_uuid(), (SELECT id FROM cpr_l2),
 'Is gasping considered normal breathing?',
 '["Yes, wait and observe","Only if it''s regular","No — begin CPR","Check again in 30 seconds"]'::jsonb,
 2, 'Gasping or gurgling is NOT normal breathing and indicates cardiac arrest — begin CPR immediately.', 4),

(gen_random_uuid(), (SELECT id FROM cpr_l2),
 'What is the difference between cardiac arrest and a heart attack?',
 '["Cardiac arrest = heart stops; heart attack = blocked artery","They are the same thing","Heart attack is more serious","Cardiac arrest only affects elderly"]'::jsonb,
 0, 'Cardiac arrest means the heart has stopped pumping. A heart attack is a blocked artery — the person is usually conscious.', 5),

-- ── CPR L3: Chest Compressions ──────────────────────────────────────────────
(gen_random_uuid(), (SELECT id FROM cpr_l3),
 'Where should you place the heel of your hand for compressions?',
 '["Centre of the chest on the breastbone","Left side of the chest","Over the stomach","On the ribs"]'::jsonb,
 0, 'The heel of the hand goes on the centre of the chest (breastbone/sternum) for maximum effectiveness.', 1),

(gen_random_uuid(), (SELECT id FROM cpr_l3),
 'What is the recommended compression depth for adults?',
 '["2 cm","At least 5 cm","8 cm","10 cm"]'::jsonb,
 1, 'Adult compressions should be at least 5 cm (about 2 inches) deep to effectively pump blood.', 2),

(gen_random_uuid(), (SELECT id FROM cpr_l3),
 'What is the correct compression rate?',
 '["60 per minute","80 per minute","100–120 per minute","150 per minute"]'::jsonb,
 2, 'The recommended rate is 100–120 compressions per minute — roughly the beat of "Stayin'' Alive."', 3),

(gen_random_uuid(), (SELECT id FROM cpr_l3),
 'What should you do between compressions?',
 '["Allow the chest to fully recoil","Push harder","Hold the compression","Lift your hands off"]'::jsonb,
 0, 'Full chest recoil between compressions allows the heart to refill with blood.', 4),

(gen_random_uuid(), (SELECT id FROM cpr_l3),
 'How often should rescuers switch during CPR?',
 '["Every 30 seconds","Every 2 minutes","Every 5 minutes","Never switch"]'::jsonb,
 1, 'Switch every 2 minutes (or every 5 cycles of 30:2) to avoid fatigue, which reduces compression quality.', 5),

-- ── CPR L4: Rescue Breathing ────────────────────────────────────────────────
(gen_random_uuid(), (SELECT id FROM cpr_l4),
 'What is the compression-to-breath ratio in CPR?',
 '["30:2","15:2","30:1","10:2"]'::jsonb,
 0, 'The standard CPR ratio is 30 compressions followed by 2 rescue breaths.', 1),

(gen_random_uuid(), (SELECT id FROM cpr_l4),
 'How do you open the airway before giving breaths?',
 '["Shake the head","Head-tilt chin-lift","Push the jaw forward","Turn the head sideways"]'::jsonb,
 1, 'The head-tilt chin-lift technique opens the airway by moving the tongue away from the back of the throat.', 2),

(gen_random_uuid(), (SELECT id FROM cpr_l4),
 'How long should each rescue breath last?',
 '["About 1 second","3 seconds","5 seconds","As long as possible"]'::jsonb,
 0, 'Each breath should last about 1 second — just enough to see the chest rise.', 3),

(gen_random_uuid(), (SELECT id FROM cpr_l4),
 'What should you do if the chest doesn''t rise during a rescue breath?',
 '["Blow harder","Give up on breaths","Reposition the head and try again","Start compressions over"]'::jsonb,
 2, 'If the chest doesn''t rise, reposition the head with the head-tilt chin-lift and attempt the breath again.', 4),

(gen_random_uuid(), (SELECT id FROM cpr_l4),
 'Is hands-only CPR effective?',
 '["Yes, it is highly effective","No, breaths are essential","Only for children","Only for the first minute"]'::jsonb,
 0, 'Hands-only CPR (continuous compressions) is highly effective, especially for untrained bystanders. The Singapore Resuscitation Council supports it.', 5),

-- ── CPR L5: CPR for Children & Infants ──────────────────────────────────────
(gen_random_uuid(), (SELECT id FROM cpr_l5),
 'Why is paediatric cardiac arrest usually different from adult cardiac arrest?',
 '["It''s usually caused by breathing problems","It''s caused by heart disease","It only happens during sleep","It''s always less serious"]'::jsonb,
 0, 'In children, cardiac arrest is most commonly caused by respiratory failure, not heart problems.', 1),

(gen_random_uuid(), (SELECT id FROM cpr_l5),
 'How many hands should you use for child CPR (ages 1-8)?',
 '["Two hands","One hand","Two fingers","One finger"]'::jsonb,
 1, 'Use one hand for chest compressions on children aged 1–8 years.', 2),

(gen_random_uuid(), (SELECT id FROM cpr_l5),
 'What technique is used for infant compressions?',
 '["Two fingers below the nipple line","One hand on the chest","Full palm on the stomach","Thumb presses"]'::jsonb,
 0, 'Use two fingers (index and middle) placed on the breastbone just below the nipple line.', 3),

(gen_random_uuid(), (SELECT id FROM cpr_l5),
 'How deep should infant compressions be?',
 '["2 cm","6 cm","About 4 cm","Same as adults"]'::jsonb,
 2, 'Infant compressions should be about 4 cm deep — approximately one-third of the chest depth.', 4),

(gen_random_uuid(), (SELECT id FROM cpr_l5),
 'What should you do first when performing CPR on a child?',
 '["Give 2 initial rescue breaths","Start compressions","Call 995","Check for a pulse"]'::jsonb,
 0, 'For children and infants, give 2 rescue breaths before starting compressions, as the arrest is usually respiratory in origin.', 5),

-- ── AED L1: What is an AED? ─────────────────────────────────────────────────
(gen_random_uuid(), (SELECT id FROM aed_l1),
 'What does AED stand for?',
 '["Automated External Defibrillator","Automatic Emergency Device","Advanced Electrical Defuser","Auto External Detector"]'::jsonb,
 0, 'AED = Automated External Defibrillator.', 1),

(gen_random_uuid(), (SELECT id FROM aed_l1),
 'Can an AED accidentally shock someone who doesn''t need it?',
 '["Yes, always be careful","No, it only shocks if needed","Sometimes","Only if used incorrectly"]'::jsonb,
 1, 'AEDs analyse the heart rhythm and will only deliver a shock if a shockable rhythm is detected.', 2),

(gen_random_uuid(), (SELECT id FROM aed_l1),
 'What app shows AED locations in Singapore?',
 '["myResponder","Google Maps","SingHealth","SGSecure"]'::jsonb,
 0, 'The SCDF myResponder app shows nearby AED locations and can alert trained volunteers during emergencies.', 3),

(gen_random_uuid(), (SELECT id FROM aed_l1),
 'Within how many minutes should defibrillation ideally occur?',
 '["1 minute","3–5 minutes","10 minutes","15 minutes"]'::jsonb,
 1, 'Defibrillation within 3–5 minutes of cardiac arrest can achieve survival rates of 50–70%.', 4),

(gen_random_uuid(), (SELECT id FROM aed_l1),
 'Do you need medical training to use an AED?',
 '["No, anyone can use it","Yes, certification required","Only doctors can use it","You need a first aid course"]'::jsonb,
 0, 'AEDs are designed for use by anyone — voice prompts guide you through every step.', 5),

-- ── AED L2: Finding AEDs in Singapore ───────────────────────────────────────
(gen_random_uuid(), (SELECT id FROM aed_l2),
 'Which public transport stations in Singapore have AEDs?',
 '["All MRT stations","Only interchange stations","Bus interchanges only","None"]'::jsonb,
 0, 'Every MRT station in Singapore is equipped with at least one AED.', 1),

(gen_random_uuid(), (SELECT id FROM aed_l2),
 'What app helps you find the nearest AED?',
 '["HealthHub","myResponder","OneService","Grab"]'::jsonb,
 1, 'The SCDF myResponder app shows nearby AED locations and provides walking directions.', 2),

(gen_random_uuid(), (SELECT id FROM aed_l2),
 'What should you do if the AED cabinet has an alarm?',
 '["Ignore the alarm and take the AED","Wait for someone to disable it","Call security first","Don''t use that AED"]'::jsonb,
 0, 'AED cabinet alarms are designed to alert others — ignore it and take the AED immediately. Every second counts.', 3),

(gen_random_uuid(), (SELECT id FROM aed_l2),
 'What does the universal AED sign look like?',
 '["Red cross","Blue circle with H","Green heart with a lightning bolt","White plus sign"]'::jsonb,
 2, 'The universal AED sign is a green heart with a lightning bolt symbol.', 4),

(gen_random_uuid(), (SELECT id FROM aed_l2),
 'Where are AEDs commonly found in HDB estates?',
 '["Void decks in glass cabinets","Inside lifts","On every floor","At the rubbish chute"]'::jsonb,
 0, 'Many HDB blocks have AEDs installed at the void deck, usually in bright cabinets.', 5),

-- ── AED L3: Using an AED Step-by-Step ───────────────────────────────────────
(gen_random_uuid(), (SELECT id FROM aed_l3),
 'What is the first thing you do when the AED arrives?',
 '["Turn it on","Attach the pads","Shout Clear","Stop CPR permanently"]'::jsonb,
 0, 'Power on the AED immediately so it can begin guiding you through the process.', 1),

(gen_random_uuid(), (SELECT id FROM aed_l3),
 'Where should the two AED pads be placed?',
 '["Upper right chest and lower left side","Both on the left chest","One on the back, one on the chest","Both on the stomach"]'::jsonb,
 0, 'One pad goes on the upper right chest (below the collarbone) and the other on the lower left side (below the armpit).', 2),

(gen_random_uuid(), (SELECT id FROM aed_l3),
 'What should you do when the AED says "Analysing rhythm"?',
 '["Continue compressions","Make sure nobody is touching the person","Remove the pads","Turn off the AED"]'::jsonb,
 1, 'During analysis, no one should touch the person as it can interfere with the reading.', 3),

(gen_random_uuid(), (SELECT id FROM aed_l3),
 'What should you shout before pressing the shock button?',
 '["Clear!","Shock!","Stand back!","Help!"]'::jsonb,
 0, 'Shout "CLEAR!" to ensure nobody is touching the person before delivering the shock.', 4),

(gen_random_uuid(), (SELECT id FROM aed_l3),
 'What do you do after the AED delivers a shock?',
 '["Wait for the AED to instruct","Remove the pads","Immediately resume CPR","Check for a pulse"]'::jsonb,
 2, 'After the shock, immediately resume CPR. The AED will re-analyse in 2 minutes.', 5),

-- ── AED L4: AED Special Situations ──────────────────────────────────────────
(gen_random_uuid(), (SELECT id FROM aed_l4),
 'What should you do if the person''s chest is wet?',
 '["Dry the chest before applying pads","Use the AED anyway","Wait for it to dry naturally","Don''t use the AED"]'::jsonb,
 0, 'Quickly dry the chest before applying AED pads to ensure good contact and safety.', 1),

(gen_random_uuid(), (SELECT id FROM aed_l4),
 'What should you do if you see a medication patch on the chest?',
 '["Place the pad over it","Remove it and wipe the area","Leave it and use the AED","Call 995 and wait"]'::jsonb,
 1, 'Remove medication patches and wipe the area to ensure proper pad contact and prevent burns.', 2),

(gen_random_uuid(), (SELECT id FROM aed_l4),
 'What pads should be used on children?',
 '["Paediatric pads if available, otherwise adult pads","Never use an AED on children","Only adult pads","Only hospital-grade pads"]'::jsonb,
 0, 'Use paediatric pads if available. If not, adult pads are safe to use — an AED is always better than no AED.', 3),

(gen_random_uuid(), (SELECT id FROM aed_l4),
 'How far should AED pads be from a pacemaker?',
 '["Directly over it","At least 10 cm","At least 2.5 cm away","At least 30 cm"]'::jsonb,
 2, 'Place AED pads at least 2.5 cm (about 1 inch) away from any implanted device.', 4),

(gen_random_uuid(), (SELECT id FROM aed_l4),
 'Can you use an AED in standing water?',
 '["No, move the person to a dry area","Yes, AEDs are waterproof","Only if you wear rubber gloves","Only if the AED is dry"]'::jsonb,
 0, 'Never use an AED in standing water — move the person to a dry surface first.', 5),

-- ── FA L1: Responding to Choking ────────────────────────────────────────────
(gen_random_uuid(), (SELECT id FROM fa_l1),
 'What is the universal sign of choking?',
 '["Clutching the throat","Waving arms","Pointing at mouth","Lying down"]'::jsonb,
 0, 'The universal choking sign is both hands clutching the throat.', 1),

(gen_random_uuid(), (SELECT id FROM fa_l1),
 'What should you do for mild choking?',
 '["Give back blows","Encourage forceful coughing","Perform the Heimlich","Call 995"]'::jsonb,
 1, 'If the person can still cough, encourage them to keep coughing forcefully — do not interfere.', 2),

(gen_random_uuid(), (SELECT id FROM fa_l1),
 'How many back blows should you give for severe choking?',
 '["5","3","10","As many as needed"]'::jsonb,
 0, 'Give 5 sharp back blows between the shoulder blades, then alternate with 5 abdominal thrusts.', 3),

(gen_random_uuid(), (SELECT id FROM fa_l1),
 'Should you use abdominal thrusts on infants?',
 '["Yes, the same technique","Only gentle ones","No, use chest thrusts instead","Only if back blows fail"]'::jsonb,
 2, 'Never use abdominal thrusts on infants — use chest thrusts (2 fingers on the breastbone) instead.', 4),

(gen_random_uuid(), (SELECT id FROM fa_l1),
 'What should you do if a choking person becomes unconscious?',
 '["Lower them down and start CPR","Keep trying back blows","Put them in recovery position","Wait for ambulance"]'::jsonb,
 0, 'If the person becomes unconscious, begin CPR. Chest compressions may help dislodge the object.', 5),

-- ── FA L2: Controlling Bleeding ─────────────────────────────────────────────
(gen_random_uuid(), (SELECT id FROM fa_l2),
 'How quickly can a person bleed to death from a major wound?',
 '["Under 5 minutes","15 minutes","30 minutes","1 hour"]'::jsonb,
 0, 'Severe bleeding can be fatal in under 5 minutes, which is why immediate action is critical.', 1),

(gen_random_uuid(), (SELECT id FROM fa_l2),
 'What should you do if the first cloth soaks through with blood?',
 '["Remove it and apply a new one","Add more cloth on top without removing the first","Apply a tourniquet","Rinse the wound"]'::jsonb,
 1, 'Never remove a blood-soaked cloth — add more layers on top and continue pressing.', 2),

(gen_random_uuid(), (SELECT id FROM fa_l2),
 'How long should you maintain direct pressure?',
 '["2 minutes","5 minutes","At least 10 minutes","Until the ambulance arrives"]'::jsonb,
 2, 'Maintain firm direct pressure for at least 10 minutes to allow clotting.', 3),

(gen_random_uuid(), (SELECT id FROM fa_l2),
 'What should you do with an embedded object in a wound?',
 '["Leave it in place and bandage around it","Pull it out carefully","Push it in further","Ignore it"]'::jsonb,
 0, 'Never remove embedded objects — this can worsen bleeding. Bandage around it and let paramedics handle it.', 4),

(gen_random_uuid(), (SELECT id FROM fa_l2),
 'What are signs of shock from blood loss?',
 '["Feeling faint, dizzy, or confused","Feeling hungry","Feeling itchy","Feeling warm"]'::jsonb,
 0, 'Faintness, dizziness, confusion, pale skin, and rapid breathing are signs of shock from blood loss.', 5),

-- ── FA L3: Treating Burns ───────────────────────────────────────────────────
(gen_random_uuid(), (SELECT id FROM fa_l3),
 'How long should you cool a burn under running water?',
 '["5 minutes","20 minutes","10 minutes","2 minutes"]'::jsonb,
 1, 'Cool a burn under cool running water for 20 minutes — this is the most important first aid step.', 1),

(gen_random_uuid(), (SELECT id FROM fa_l3),
 'Which of these should you NEVER apply to a burn?',
 '["Ice or butter","Cool water","Cling film","A clean cloth"]'::jsonb,
 0, 'Never apply ice, butter, toothpaste, or other home remedies — these can worsen the injury.', 2),

(gen_random_uuid(), (SELECT id FROM fa_l3),
 'When should you call 995 for a burn?',
 '["Burns larger than the person''s palm","Only for fire-related burns","Only if there are blisters","Only for children"]'::jsonb,
 0, 'Call 995 for burns larger than a palm, on sensitive areas, or for chemical/electrical burns.', 3),

(gen_random_uuid(), (SELECT id FROM fa_l3),
 'What should you use to cover a burn after cooling?',
 '["Cotton wool","Cling film or a clean non-fluffy cloth","A bandage","Tissue paper"]'::jsonb,
 1, 'Cover with cling film or a clean, non-fluffy cloth to protect the burn and prevent infection.', 4),

(gen_random_uuid(), (SELECT id FROM fa_l3),
 'What is the most common cause of burns in Singapore homes?',
 '["Hot liquids (scalds)","Electrical fires","Chemical spills","Sunburn"]'::jsonb,
 0, 'Scalds from hot water, soup, and oil are the most common burns in Singapore kitchens.', 5),

-- ── FA L4: Fractures & Sprains ──────────────────────────────────────────────
(gen_random_uuid(), (SELECT id FROM fa_l4),
 'What should you NEVER do with a suspected fracture?',
 '["Try to straighten or realign the bone","Apply ice","Call for help","Keep the limb still"]'::jsonb,
 0, 'Never attempt to realign a broken bone — this can cause further damage to blood vessels and nerves.', 1),

(gen_random_uuid(), (SELECT id FROM fa_l4),
 'What does RICE stand for?',
 '["Run, Ice, Call, Elevate","Rest, Ice, Compression, Elevation","Rest, Immobilise, Cool, Exercise","Reduce, Ice, Cover, Evaluate"]'::jsonb,
 1, 'RICE = Rest, Ice, Compression, Elevation — the standard first aid for sprains.', 2),

(gen_random_uuid(), (SELECT id FROM fa_l4),
 'How long should you apply ice to a sprain?',
 '["20 minutes every 2 hours","5 minutes once","Continuously","1 hour"]'::jsonb,
 0, 'Apply ice for 20 minutes every 2 hours, wrapped in a cloth to prevent frostbite.', 3),

(gen_random_uuid(), (SELECT id FROM fa_l4),
 'What is an open fracture?',
 '["A fracture that heals on its own","A hairline crack","Bone visible through the skin","A dislocated joint"]'::jsonb,
 2, 'An open (compound) fracture means the bone has broken through the skin — this requires immediate emergency care.', 4),

(gen_random_uuid(), (SELECT id FROM fa_l4),
 'When should you see a doctor for a sprain?',
 '["If you can''t bear weight or swelling persists after 48 hours","Only if it''s on your leg","After 2 weeks","Only if there''s bruising"]'::jsonb,
 0, 'See a doctor if you can''t bear weight on the limb or swelling hasn''t improved after 48 hours.', 5),

-- ── FA L5: Heat Injuries in Singapore ───────────────────────────────────────
(gen_random_uuid(), (SELECT id FROM fa_l5),
 'Why is Singapore especially high-risk for heat injuries?',
 '["High humidity prevents sweat from evaporating","It''s the hottest country","No air conditioning","People don''t drink water"]'::jsonb,
 0, 'Singapore''s high humidity (often 80%+) prevents sweat from evaporating, making it harder for the body to cool down.', 1),

(gen_random_uuid(), (SELECT id FROM fa_l5),
 'What is the key sign that distinguishes heatstroke from heat exhaustion?',
 '["Sweating has stopped, skin is hot and dry","Heavy sweating","Muscle cramps","Feeling tired"]'::jsonb,
 0, 'In heatstroke, the body''s cooling system fails — sweating stops and the skin becomes hot, red, and dry.', 2),

(gen_random_uuid(), (SELECT id FROM fa_l5),
 'What is the first thing to do for someone with heatstroke?',
 '["Call 995 immediately","Give them water","Tell them to rest","Apply sunscreen"]'::jsonb,
 0, 'Heatstroke is a life-threatening emergency. Call 995 immediately while cooling the person aggressively.', 3),

(gen_random_uuid(), (SELECT id FROM fa_l5),
 'Where should you apply ice packs to cool someone with heatstroke?',
 '["Forehead only","Hands and feet","Neck, armpits, and groin","Stomach"]'::jsonb,
 2, 'Apply ice packs to areas with major blood vessels — neck, armpits, and groin — for the fastest cooling.', 4),

(gen_random_uuid(), (SELECT id FROM fa_l5),
 'How much water should you drink per hour during outdoor activity?',
 '["100 ml","At least 500 ml","1 litre every 3 hours","Only when thirsty"]'::jsonb,
 1, 'Drink at least 500 ml of water per hour during outdoor activity in Singapore''s heat.', 5),

-- ── FS L1: Fire Hazards in Singapore ────────────────────────────────────────
(gen_random_uuid(), (SELECT id FROM fs_l1),
 'What is the #1 cause of residential fires in Singapore?',
 '["Unattended cooking","Electrical faults","Smoking","Arson"]'::jsonb,
 0, 'Unattended cooking is the leading cause of residential fires in Singapore.', 1),

(gen_random_uuid(), (SELECT id FROM fs_l1),
 'What should you do if a pot of oil catches fire?',
 '["Pour water on it","Cover it with a lid","Blow on it","Move the pot"]'::jsonb,
 1, 'Cover the pot with a lid to smother the flames. NEVER use water on an oil fire — it causes a dangerous fireball.', 2),

(gen_random_uuid(), (SELECT id FROM fs_l1),
 'How should you avoid electrical fires?',
 '["Use one plug per socket","Use as many plugs as needed","Only use extension cords","Leave appliances on standby"]'::jsonb,
 0, 'Avoid overloading sockets. Use one plug per socket and switch off appliances when not in use.', 3),

(gen_random_uuid(), (SELECT id FROM fs_l1),
 'When are joss paper burning fires most common?',
 '["Chinese New Year","Deepavali","Hungry Ghost Festival and Qing Ming","Christmas"]'::jsonb,
 2, 'Fires from joss paper burning peak during the Hungry Ghost Festival (7th month) and Qing Ming Festival.', 4),

(gen_random_uuid(), (SELECT id FROM fs_l1),
 'What should you do with a swollen PMD battery?',
 '["Stop using it and dispose of it properly","Keep charging it","Use a different charger","Puncture it to release pressure"]'::jsonb,
 0, 'A swollen battery is a fire risk. Stop using it immediately and bring it to a proper disposal point.', 5),

-- ── FS L2: Using a Fire Extinguisher ────────────────────────────────────────
(gen_random_uuid(), (SELECT id FROM fs_l2),
 'What does PASS stand for?',
 '["Pull, Aim, Squeeze, Sweep","Push, Aim, Spray, Stop","Pull, Activate, Spray, Sweep","Push, Aim, Squeeze, Spray"]'::jsonb,
 0, 'PASS = Pull the pin, Aim at the base, Squeeze the handle, Sweep side to side.', 1),

(gen_random_uuid(), (SELECT id FROM fs_l2),
 'Where should you aim the fire extinguisher?',
 '["At the base of the fire","At the top of the flames","At the smoke","Directly at the centre"]'::jsonb,
 0, 'Aim at the BASE of the fire where the fuel is burning, not at the flames above.', 2),

(gen_random_uuid(), (SELECT id FROM fs_l2),
 'When should you NOT try to fight a fire?',
 '["When you have an extinguisher","When the room is filled with smoke","When the fire is small","When you have an escape route"]'::jsonb,
 1, 'Do not fight a fire if the room is full of smoke, you don''t have a clear escape route, or the fire is too large.', 3),

(gen_random_uuid(), (SELECT id FROM fs_l2),
 'What type of extinguisher is best for home use?',
 '["ABC Dry Powder","CO2","Water","Foam"]'::jsonb,
 0, 'ABC dry powder extinguishers work on most fire types and are the best all-round choice for homes.', 4),

(gen_random_uuid(), (SELECT id FROM fs_l2),
 'How far should you stand from the fire when using an extinguisher?',
 '["30 cm","1.5–2 metres","5 metres","10 metres"]'::jsonb,
 1, 'Stand 1.5–2 metres from the fire for effective extinguishing while maintaining a safe distance.', 5),

-- ── FS L3: HDB & High-Rise Evacuation ──────────────────────────────────────
(gen_random_uuid(), (SELECT id FROM fs_l3),
 'What should you use to evacuate a high-rise building?',
 '["Staircases","Lifts","Windows","Balcony"]'::jsonb,
 0, 'Always use staircases during a fire. Lifts may stop working or fill with smoke.', 1),

(gen_random_uuid(), (SELECT id FROM fs_l3),
 'What does the R in RACE stand for?',
 '["Rescue","Run","React","Report"]'::jsonb,
 0, 'RACE = Rescue, Alarm, Contain, Evacuate.', 2),

(gen_random_uuid(), (SELECT id FROM fs_l3),
 'What should you do if a door feels hot?',
 '["Open it quickly","Use another escape route","Break it down","Wait by the door"]'::jsonb,
 1, 'A hot door means fire is on the other side. Use an alternative route.', 3),

(gen_random_uuid(), (SELECT id FROM fs_l3),
 'How long can a closed door hold back fire?',
 '["5 minutes","2 hours","Up to 30 minutes","It makes no difference"]'::jsonb,
 2, 'A closed door can resist fire and smoke for up to 30 minutes, buying critical time.', 4),

(gen_random_uuid(), (SELECT id FROM fs_l3),
 'If you are trapped, what should you tell 995?',
 '["Your exact unit number and floor","Just help","Your name only","Your IC number"]'::jsonb,
 0, 'Give your exact unit number and floor so SCDF can locate you quickly.', 5),

-- ── FS L4: Smoke Inhalation & Burns ─────────────────────────────────────────
(gen_random_uuid(), (SELECT id FROM fs_l4),
 'What causes most fire-related deaths?',
 '["Smoke inhalation","Burns","Falling debris","Explosions"]'::jsonb,
 0, 'Most fire deaths are caused by inhaling toxic smoke, not by the fire itself.', 1),

(gen_random_uuid(), (SELECT id FROM fs_l4),
 'How many breaths of toxic smoke can cause unconsciousness?',
 '["10 breaths","2–3 breaths","20 breaths","Only prolonged exposure"]'::jsonb,
 1, 'Just 2–3 breaths of thick, toxic smoke can render a person unconscious.', 2),

(gen_random_uuid(), (SELECT id FROM fs_l4),
 'What should you do in a smoky room?',
 '["Crawl on hands and knees","Run upright","Stand still","Open windows first"]'::jsonb,
 0, 'Smoke rises — breathable air is near the floor. Crawl to stay below the smoke.', 3),

(gen_random_uuid(), (SELECT id FROM fs_l4),
 'How often should you test your smoke detector?',
 '["Monthly","Yearly","Daily","Only when installed"]'::jsonb,
 0, 'Test your smoke detector monthly by pressing the test button to ensure it works.', 4),

(gen_random_uuid(), (SELECT id FROM fs_l4),
 'How long should you cool a burn under water?',
 '["2 minutes","5 minutes","20 minutes","10 minutes"]'::jsonb,
 2, 'Cool burns under running water for 20 minutes to reduce damage and pain.', 5),

-- ── EP L1: Singapore Emergency Numbers ──────────────────────────────────────
(gen_random_uuid(), (SELECT id FROM ep_l1),
 'What is the number for ambulance and fire in Singapore?',
 '["995","999","911","112"]'::jsonb,
 0, '995 is the SCDF number for ambulance and fire emergencies.', 1),

(gen_random_uuid(), (SELECT id FROM ep_l1),
 'What number should you call for police?',
 '["995","999","911","110"]'::jsonb,
 1, '999 is the Singapore Police Force (SPF) emergency number.', 2),

(gen_random_uuid(), (SELECT id FROM ep_l1),
 'What is the non-emergency ambulance number?',
 '["995","999","1777","1800"]'::jsonb,
 2, '1777 is for non-life-threatening medical transport.', 3),

(gen_random_uuid(), (SELECT id FROM ep_l1),
 'What does the myResponder app do?',
 '["Alerts CPR-trained volunteers and shows AED locations","Books doctor appointments","Calls 995 automatically","Tracks your fitness"]'::jsonb,
 0, 'The SCDF myResponder app alerts nearby CPR-trained volunteers and shows AED locations during cardiac emergencies.', 4),

(gen_random_uuid(), (SELECT id FROM ep_l1),
 'Can you call 995 from a locked phone?',
 '["Yes, even without a SIM card","No, you must unlock first","Only with a SIM card","Only from a landline"]'::jsonb,
 0, 'Emergency numbers 995 and 999 can be dialled from any phone, even locked or without a SIM card.', 5),

-- ── EP L2: Calling 995 Effectively ─────────────────────────────────────────
(gen_random_uuid(), (SELECT id FROM ep_l2),
 'What are the 5 W''s you should tell the dispatcher?',
 '["What, Where, Who, When, What you''ve done","Who, What, When, Where, Why","What, Where, Which, When, Weather","Who, What, Which, When, Where"]'::jsonb,
 0, 'Tell the dispatcher: What happened, Where you are, Who needs help, When it happened, and What you''ve done so far.', 1),

(gen_random_uuid(), (SELECT id FROM ep_l2),
 'What language can you speak when calling 995?',
 '["English, Mandarin, Malay, or Tamil","Only English","Only English and Mandarin","Any language"]'::jsonb,
 0, 'SCDF dispatchers are multilingual and can handle calls in Singapore''s four official languages.', 2),

(gen_random_uuid(), (SELECT id FROM ep_l2),
 'How should you give your location if you''re in an HDB?',
 '["Block number, street, level, and unit number","Just the street name","Just I''m at home","The postal code only"]'::jsonb,
 0, 'Be specific: give the block number, street name, level, and unit number for the fastest response.', 3),

(gen_random_uuid(), (SELECT id FROM ep_l2),
 'Should you hang up after telling the dispatcher what happened?',
 '["Yes, so the line is free","No, stay on the line until told to hang up","After 2 minutes","Only if you''re doing CPR"]'::jsonb,
 1, 'Stay on the line — the dispatcher may give you life-saving instructions while help is on the way.', 4),

(gen_random_uuid(), (SELECT id FROM ep_l2),
 'How can you help paramedics find you faster?',
 '["Send someone to meet them at the entrance","Flash your lights","Shout from the window","Send a text to 995"]'::jsonb,
 0, 'Sending a runner to the void deck or building entrance to guide paramedics can save 2–3 minutes.', 5),

-- ── EP L3: Building an Emergency Kit ────────────────────────────────────────
(gen_random_uuid(), (SELECT id FROM ep_l3),
 'How many days should your emergency kit sustain your family?',
 '["At least 3 days (72 hours)","1 day","1 week","1 month"]'::jsonb,
 0, 'The 72-hour principle: be prepared to be self-sufficient for at least 3 days after a major emergency.', 1),

(gen_random_uuid(), (SELECT id FROM ep_l3),
 'How much water per person per day should you store?',
 '["1 litre","3 litres","500 ml","5 litres"]'::jsonb,
 1, 'Store at least 3 litres of water per person per day — that''s a minimum of 9 litres per person for 72 hours.', 2),

(gen_random_uuid(), (SELECT id FROM ep_l3),
 'Why should you keep a printed emergency contact list?',
 '["Phone batteries may die or networks may fail","Phones don''t have contacts","It''s required by law","To give to neighbours"]'::jsonb,
 0, 'During emergencies, phones may run out of battery and networks may be overloaded — a printed list is a reliable backup.', 3),

(gen_random_uuid(), (SELECT id FROM ep_l3),
 'How often should you review your emergency kit?',
 '["Every 6 months","Every year","Every month","Only once"]'::jsonb,
 0, 'Review every 6 months to replace expired food, medication, and refresh batteries and power banks.', 4),

(gen_random_uuid(), (SELECT id FROM ep_l3),
 'What form of money should you keep in your emergency kit?',
 '["Credit cards","Digital wallet","Cash in small denominations","Cheques"]'::jsonb,
 2, 'Keep cash in small denominations — ATMs and electronic payment systems may not work during a major emergency.', 5),

-- ── EP L4: Haze, Floods & Severe Weather ────────────────────────────────────
(gen_random_uuid(), (SELECT id FROM ep_l4),
 'What PSI reading is considered "Unhealthy"?',
 '["101–200","50–100","201–300","300+"]'::jsonb,
 0, 'PSI 101–200 is "Unhealthy" — reduce prolonged outdoor activity, especially for vulnerable groups.', 1),

(gen_random_uuid(), (SELECT id FROM ep_l4),
 'What type of mask protects against haze?',
 '["Surgical mask","N95 mask","Cloth mask","Any face covering"]'::jsonb,
 1, 'Only N95 masks effectively filter the fine particles in haze. Surgical and cloth masks do not provide adequate protection.', 2),

(gen_random_uuid(), (SELECT id FROM ep_l4),
 'What should you do during flash flooding?',
 '["Move to higher ground","Walk through the water","Drive through it","Go to the basement"]'::jsonb,
 0, 'Never walk or drive through floodwater. Move to higher ground and avoid underground spaces.', 3),

(gen_random_uuid(), (SELECT id FROM ep_l4),
 'How many lightning days does Singapore average per year?',
 '["186","50","100","365"]'::jsonb,
 0, 'Singapore averages 186 lightning days per year, making it one of the world''s lightning hotspots.', 4),

(gen_random_uuid(), (SELECT id FROM ep_l4),
 'How long should you wait after the last thunder before going outside?',
 '["5 minutes","10 minutes","30 minutes","1 hour"]'::jsonb,
 2, 'Wait at least 30 minutes after the last thunder before going outside — lightning can strike even after rain stops.', 5),

-- ── EP L5: Family Emergency Planning ────────────────────────────────────────
(gen_random_uuid(), (SELECT id FROM ep_l5),
 'How often should you practice your family emergency plan?',
 '["At least once a year","Every month","Only once","Every 5 years"]'::jsonb,
 0, 'Practice your plan at least once a year to ensure everyone remembers what to do.', 1),

(gen_random_uuid(), (SELECT id FROM ep_l5),
 'What is the "Run, Hide, Tell" protocol for?',
 '["Fire emergencies","Flooding","Terror threats","Earthquakes"]'::jsonb,
 2, '"Run, Hide, Tell" is Singapore''s SGSecure response protocol for terror attacks: Run to safety, Hide if you can''t run, Tell authorities.', 2),

(gen_random_uuid(), (SELECT id FROM ep_l5),
 'Why should you have an out-of-town contact?',
 '["They can relay messages if local networks are overloaded","To have someone to visit","For holiday planning","It''s a legal requirement"]'::jsonb,
 0, 'Local phone networks may be overloaded during emergencies. An out-of-town contact can coordinate communication.', 3),

(gen_random_uuid(), (SELECT id FROM ep_l5),
 'What should you teach young children?',
 '["To recite their parents'' phone numbers","How to drive","How to call the police","How to use the fire extinguisher"]'::jsonb,
 0, 'Teach children to recite parents'' phone numbers — this helps if they are separated during an emergency.', 4),

(gen_random_uuid(), (SELECT id FROM ep_l5),
 'What date is Total Defence Day in Singapore?',
 '["9 August","15 February","1 January","25 December"]'::jsonb,
 1, 'Total Defence Day is observed on 15 February each year, marking the fall of Singapore in 1942 and reminding citizens to be prepared.', 5);
