-- ============================================================
-- ReadySG Emergency Guides Seed Data v2 — Content Overhaul
--
-- PREREQUISITE: Run schema_migration.sql first.
-- Safe to re-run: cleanup + fresh insert.
--
-- 10 guides covering the most critical emergency scenarios
-- for Singapore residents.
-- ============================================================

DELETE FROM emergency_guides;

INSERT INTO emergency_guides (title, description, content, sort_order, is_published)
VALUES

-- ─── 1. CPR (Adult) ────────────────────────────────────────────────────────
(
  'CPR (Adult)',
  'Step-by-step CPR for an unresponsive adult — from checking response to continuous compressions.',
  $json$[
    {
      "type": "text",
      "title": "Check for Response",
      "body": "Tap shoulders, shout \"Are you okay?\". If no response, shout for help."
    },
    {
      "type": "text",
      "title": "Call 995",
      "body": "Call 995 on speakerphone. Tell them: location, someone is unresponsive and not breathing."
    },
    {
      "type": "text",
      "title": "Open the Airway",
      "body": "Head-tilt chin-lift: one hand on forehead, two fingers under chin, tilt back gently."
    },
    {
      "type": "text",
      "title": "Check for Breathing",
      "body": "Look, listen, feel for 10 seconds. Gasping is NOT normal breathing."
    },
    {
      "type": "text",
      "title": "30 Chest Compressions",
      "body": "Heel of hand on centre of chest, push 5 cm deep, rate 100–120/min."
    },
    {
      "type": "text",
      "title": "2 Rescue Breaths",
      "body": "Pinch nose, seal mouth, blow for 1 second. Watch for chest rise."
    },
    {
      "type": "text",
      "title": "Continue Until Help Arrives",
      "body": "Repeat 30:2 cycle. Switch with another rescuer every 2 min. Don't stop until paramedics take over."
    }
  ]$json$::jsonb,
  1, true
),

-- ─── 2. CPR (Child & Infant) ───────────────────────────────────────────────
(
  'CPR (Child & Infant)',
  'Modified CPR for children (1-8 years) and infants (under 1 year).',
  $json$[
    {
      "type": "text",
      "title": "Check for Response",
      "body": "Child: tap & shout. Infant: tap the foot and flick the sole."
    },
    {
      "type": "text",
      "title": "Call 995",
      "body": "If alone, give 2 minutes of CPR first, then call 995. If with others, have someone call immediately."
    },
    {
      "type": "text",
      "title": "Give 2 Rescue Breaths First",
      "body": "Open airway. Child: pinch nose, mouth-to-mouth. Infant: cover mouth AND nose."
    },
    {
      "type": "text",
      "title": "Child Compressions (1-8 years)",
      "body": "One hand on breastbone, push 5 cm deep, rate 100–120/min."
    },
    {
      "type": "text",
      "title": "Infant Compressions (Under 1)",
      "body": "Two fingers on breastbone just below nipple line, push 4 cm deep."
    },
    {
      "type": "text",
      "title": "Continue 30:2 Cycle",
      "body": "30 compressions, 2 breaths. Continue until paramedics arrive."
    }
  ]$json$::jsonb,
  2, true
),

-- ─── 3. Using an AED ───────────────────────────────────────────────────────
(
  'Using an AED',
  'How to use an Automated External Defibrillator — power on, attach pads, shock, resume CPR.',
  $json$[
    {
      "type": "text",
      "title": "Turn On the AED",
      "body": "Press the power button or open the lid. Follow the voice prompts."
    },
    {
      "type": "text",
      "title": "Expose the Chest",
      "body": "Remove clothing. Dry the chest if wet. Shave excessive hair if needed."
    },
    {
      "type": "text",
      "title": "Attach the Pads",
      "body": "Upper right chest below collarbone + lower left side below armpit. Press firmly."
    },
    {
      "type": "text",
      "title": "Analyse & Shock",
      "body": "Don't touch the person during analysis. If shock advised, shout \"CLEAR!\" and press button."
    },
    {
      "type": "text",
      "title": "Resume CPR",
      "body": "Immediately resume CPR after shock. AED will re-analyse every 2 minutes. Don't remove pads."
    }
  ]$json$::jsonb,
  3, true
),

-- ─── 4. Choking ─────────────────────────────────────────────────────────────
(
  'Choking',
  'Recognise and respond to choking in adults and infants using back blows and thrusts.',
  $json$[
    {
      "type": "text",
      "title": "Recognise Choking",
      "body": "Person clutches throat, cannot speak/cough/breathe, face turning red/blue."
    },
    {
      "type": "text",
      "title": "Encourage Coughing",
      "body": "If they can cough, encourage forceful coughing. Do NOT slap the back."
    },
    {
      "type": "text",
      "title": "5 Back Blows",
      "body": "Stand behind, lean person forward. Give 5 sharp blows between shoulder blades."
    },
    {
      "type": "text",
      "title": "5 Abdominal Thrusts",
      "body": "Stand behind, fist above navel, pull sharply inward and upward. Repeat."
    },
    {
      "type": "text",
      "title": "Infant Choking",
      "body": "Face-down on forearm: 5 back blows. Face-up: 5 chest thrusts with 2 fingers."
    },
    {
      "type": "text",
      "title": "If Unconscious",
      "body": "Lower to ground, call 995, begin CPR. Compressions may dislodge the object."
    }
  ]$json$::jsonb,
  4, true
),

-- ─── 5. Severe Bleeding ────────────────────────────────────────────────────
(
  'Severe Bleeding',
  'Control life-threatening bleeding with direct pressure, elevation, and when to call 995.',
  $json$[
    {
      "type": "text",
      "title": "Protect Yourself",
      "body": "Wear gloves or use a plastic bag. Avoid direct contact with blood."
    },
    {
      "type": "text",
      "title": "Apply Direct Pressure",
      "body": "Press clean cloth firmly on wound. Use both hands. Push hard."
    },
    {
      "type": "text",
      "title": "Don't Remove the Cloth",
      "body": "If it soaks through, add more on top. Maintain pressure for 10+ minutes."
    },
    {
      "type": "text",
      "title": "Elevate the Limb",
      "body": "Raise the injured area above heart level if possible."
    },
    {
      "type": "text",
      "title": "Embedded Objects",
      "body": "Do NOT remove. Bandage around the object to keep it stable."
    },
    {
      "type": "text",
      "title": "Call 995",
      "body": "Call for spurting blood, wounds that won't stop, deep cuts, or signs of shock."
    }
  ]$json$::jsonb,
  5, true
),

-- ─── 6. Burns ───────────────────────────────────────────────────────────────
(
  'Burns',
  'Immediate first aid for thermal, chemical, and electrical burns — cool, cover, call.',
  $json$[
    {
      "type": "text",
      "title": "Stop the Burning",
      "body": "Remove from heat source. Remove clothing/jewellery near the burn."
    },
    {
      "type": "text",
      "title": "Cool for 20 Minutes",
      "body": "Run cool water over the burn for 20 minutes. NOT ice cold."
    },
    {
      "type": "text",
      "title": "Do NOT Apply",
      "body": "No ice, butter, toothpaste, or soy sauce. These make burns worse."
    },
    {
      "type": "text",
      "title": "Cover the Burn",
      "body": "Use cling film or a clean, non-fluffy cloth. Do not wrap tightly."
    },
    {
      "type": "text",
      "title": "Call 995 For",
      "body": "Burns larger than a palm, face/neck/hand/groin burns, chemical/electrical burns."
    }
  ]$json$::jsonb,
  6, true
),

-- ─── 7. Heart Attack ───────────────────────────────────────────────────────
(
  'Heart Attack',
  'Recognise heart attack symptoms, call 995, administer aspirin, and monitor the person.',
  $json$[
    {
      "type": "text",
      "title": "Recognise the Signs",
      "body": "Crushing chest pain, pain spreading to arm/jaw/back, shortness of breath, cold sweat, nausea."
    },
    {
      "type": "text",
      "title": "Call 995 Immediately",
      "body": "Tell dispatcher: \"Suspected heart attack.\" Give location. Don't drive to hospital."
    },
    {
      "type": "text",
      "title": "Help Them Rest",
      "body": "Sit them in a comfortable position (usually half-sitting). Loosen tight clothing."
    },
    {
      "type": "text",
      "title": "Aspirin",
      "body": "If not allergic and conscious, give one 300mg aspirin. Tell them to chew, not swallow whole."
    },
    {
      "type": "text",
      "title": "Monitor Constantly",
      "body": "Watch for loss of consciousness or breathing stopping. Be ready to start CPR."
    },
    {
      "type": "text",
      "title": "If They Collapse",
      "body": "If they become unresponsive and stop breathing, begin CPR immediately. Use an AED if available."
    }
  ]$json$::jsonb,
  7, true
),

-- ─── 8. Stroke (FAST) ──────────────────────────────────────────────────────
(
  'Stroke (FAST)',
  'Use the FAST test to identify a stroke and act immediately — every minute counts.',
  $json$[
    {
      "type": "text",
      "title": "F — Face",
      "body": "Ask them to smile. Does one side of the face droop?"
    },
    {
      "type": "text",
      "title": "A — Arms",
      "body": "Ask them to raise both arms. Does one arm drift downward?"
    },
    {
      "type": "text",
      "title": "S — Speech",
      "body": "Ask them to repeat a simple sentence. Is their speech slurred or strange?"
    },
    {
      "type": "text",
      "title": "T — Time",
      "body": "If ANY of these signs are present, call 995 immediately. Note the time symptoms started."
    },
    {
      "type": "text",
      "title": "While Waiting",
      "body": "Keep them comfortable. Do not give food or drink. If they become unconscious, place in recovery position. Be ready to start CPR."
    }
  ]$json$::jsonb,
  8, true
),

-- ─── 9. Fire Emergency ─────────────────────────────────────────────────────
(
  'Fire Emergency',
  'Raise the alarm, evacuate safely, use PASS for small fires, and what to do if trapped.',
  $json$[
    {
      "type": "text",
      "title": "Raise the Alarm",
      "body": "Shout \"FIRE!\" Activate the fire alarm. Alert everyone nearby."
    },
    {
      "type": "text",
      "title": "Evacuate Immediately",
      "body": "Use staircases, NOT lifts. Stay low if there's smoke."
    },
    {
      "type": "text",
      "title": "Close Doors Behind You",
      "body": "Every closed door slows the fire. Don't go back for belongings."
    },
    {
      "type": "text",
      "title": "Small Fire? PASS.",
      "body": "Pull pin, Aim at base, Squeeze handle, Sweep side to side. Only if safe."
    },
    {
      "type": "text",
      "title": "If Trapped",
      "body": "Close doors, seal gaps with wet towels, go to a window, signal for help."
    },
    {
      "type": "text",
      "title": "Call 995",
      "body": "Once safe, call 995. Give address and floor. Guide SCDF to the location."
    }
  ]$json$::jsonb,
  9, true
),

-- ─── 10. Heatstroke ─────────────────────────────────────────────────────────
(
  'Heatstroke',
  'Recognise heatstroke, call 995, and cool the person rapidly — a life-threatening emergency.',
  $json$[
    {
      "type": "text",
      "title": "Recognise Heatstroke",
      "body": "Hot dry skin (no sweating), confusion, rapid pulse, body temp above 40°C."
    },
    {
      "type": "text",
      "title": "Call 995",
      "body": "Heatstroke is life-threatening. Call 995 immediately."
    },
    {
      "type": "text",
      "title": "Move to Cool Area",
      "body": "Move to shade or air-con. Remove excess clothing."
    },
    {
      "type": "text",
      "title": "Cool Rapidly",
      "body": "Ice packs on neck, armpits, groin. Wet cloths and fan vigorously."
    },
    {
      "type": "text",
      "title": "If Conscious",
      "body": "Give small sips of cool water. Do NOT give fluids if unconscious."
    },
    {
      "type": "text",
      "title": "Prevention",
      "body": "Drink 500 ml+ water per hour outdoors. Avoid activity 10 am–4 pm. Check NEA heat advisory."
    }
  ]$json$::jsonb,
  10, true
);
