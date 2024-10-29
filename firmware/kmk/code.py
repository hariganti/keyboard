print('Starting')

import time
import board
import digitalio

from kmk.keys                   import KC               as K
from kmk.scanners               import DiodeOrientation
from kmk.kmk_keyboard           import KMKKeyboard
from kmk.modules.layers         import Layers
from kmk.modules.holdtap        import HoldTap
from kmk.modules.sticky_keys    import StickyKeys
from kmk.extensions.media_keys  import MediaKeys

led           = digitalio.DigitalInOut(board.LED)
led.direction = digitalio.Direction.OUTPUT

### Keyboard Config ###
keyboard                    = KMKKeyboard()
keyboard.diode_orientation  = DiodeOrientation.ROW2COL
keyboard.row_pins           = (board.GP6, board.GP7, board.GP8, board.GP9)
keyboard.col_pins           = (
  board.GP23,
  board.GP27,
  board.GP22,
  board.GP21,
  board.GP26,
  board.GP20,
  board.GP28,
  board.GP2,
  board.GP10,
  board.GP5,
  board.GP29,
  board.GP4,
  board.GP3,
)

### Modules & Extensions ###
keyboard.modules.append(Layers())
keyboard.modules.append(HoldTap())
keyboard.modules.append(StickyKeys())
keyboard.extensions.append(MediaKeys())

### Layers ###
LDEF = 0 # Base
LNUM = 1 # Numpad
LSYM = 2 # Symbols
LNAV = 3 # Navigation
LMED = 4 # Media
LPTT = 5 # Push-to-Talk

### Custom Actions ###                              Tap                 | Hold
# Layer hold/toggle actions
LDEF_T = K.TO(LDEF)                               # LAYER Base
LNAV_A = K.TT(LNAV)                               # LAYER Navigation    | LAYER Navigation
LNUM_A = K.TT(LNUM)                               # LAYER Numpad        | LAYER Numpad
LSYM_A = K.TT(LSYM)                               # LAYER Symbols       | LAYER Symbols
LMED_A = K.LT(LMED, K.RALT)                       # Alt                 | LAYER Media

# Space mods
CTL = K.HT(K.SPC, K.LCTL, tap_interrupted = True) # Space               | Ctrl
GUI = K.HT(K.SPC, K.LGUI, tap_interrupted = True) # Space               | Super
ALT = K.HT(K.SPC, K.LALT, tap_interrupted = True) # Space               | Alt

# Sticky shifts
SFT  = K.SK(K.LSFT)                               # Shift               | Shift
SFLK = K.HT(K.NO, K.LSFT)                         # NONE                | Shift

# M
M1 = K.HT(K.LGUI(K.SPC), K.LGUI(K.L))             # Super + Space       | Super + L
M2 = K.HT(K.LGUI(K.E),   LDEF_T)                  # Super + E           | LAYER Base

# Movement
FTAB = K.LCTL(K.TAB)                              # Ctrl  + Tab
RTAB = K.LCTL(K.LSFT(K.TAB))                      # Ctrl  + Shift + Tab
FCON = K.LGUI(K.TAB)                              # Super + Tab
RCON = K.LGUI(K.LSFT(K.TAB))                      # Super + Shift + Tab
FSEC = K.LALT(K.TAB)                              # Alt   + Tab
RSEC = K.LALT(K.LSFT(K.TAB))                      # Alt   + Shift + Tab
FSUB = K.TAB                                      # Tab
RSUB = K.LSFT(K.TAB)                              # Shift + Tab
SENT = K.LSFT(K.ENT)                              # Shift + Enter

# Window Management
GAPS = K.LGUI(K.F)                                # Super + F
FLOT = K.LSFT(K.F1)                               # Shift + F1
ROTL = K.LSFT(K.F2)                               # Shift + F2
ROTR = K.LSFT(K.F3)                               # Shift + F3
DIST = K.LSFT(K.F4)                               # Shift + F4
SRNK = K.LSFT(K.F5)                               # Shift + F5
GROW = K.LSFT(K.F6)                               # Shift + F6

# Workspaces
WKSP1 = K.LGUI(K.N1)                              # Super + 1
WKSP2 = K.LGUI(K.N2)                              # Super + 2
WKSP3 = K.LGUI(K.N3)                              # Super + 3
WKSP4 = K.LGUI(K.N4)                              # Super + 4
WKSP5 = K.LGUI(K.N5)                              # Super + 5
WKSP6 = K.LGUI(K.N6)                              # Super + 6
WKSP7 = K.LGUI(K.N7)                              # Super + 7
WKSP8 = K.LGUI(K.N8)                              # Super + 8
WKSP9 = K.LGUI(K.N9)                              # Super + 9
WKSP0 = K.LGUI(K.N0)                              # Super + 0

# Media
MICM = K.LSFT(K.MUTE)

### Keymap ###
keyboard.keymap = [ # TODO: Add top layer with arrow keys as Home/End, Page Up/Down as selectable from any layer
                    # Might be easier to use combos for the symbol layer (` + Left = Home)
  [ # 0 - Base
    # 1     2       3       4       5       6       7       8       9       10      11      12      13
    K.TAB,  K.Q,    K.W,    K.E,    K.R,    K.T,    K.Y,    K.U,    K.I,    K.O,    K.P,    K.LBRC, K.RBRC, # 1
    LNAV_A, K.A,    K.S,    K.D,    K.F,    K.G,    K.H,    K.J,    K.K,    K.L,    K.SCLN, K.QUOT, K.ENT,  # 2
    SFT,    K.Z,    K.X,    K.C,    K.V,    K.B,    K.N,    K.M,    K.COMM, K.DOT,  K.SLSH, K.BSLS, K.UP,   # 3
    M1,     M2,     LNUM_A, LSYM_A, CTL,    GUI,    ALT,    LMED_A, K.LEFT, K.DOWN, K.RGHT, K.DEL,  K.BSPC, # 4
  ],
  [ # 1 - Numpad
    # 1     2       3       4       5       6       7       8       9       10      11      12      13
    K.ESC,  K.NO,   K.NO,   K.NO,   K.NO,   K.NO,   RSUB,   K.KP_7, K.KP_8, K.KP_9, K.PPLS, K.PMNS, FSUB,   # 1
    K.TRNS, K.NO,   K.NO,   K.NO,   K.NO,   K.NO,   SENT,   K.KP_4, K.KP_5, K.KP_6, K.PAST, K.PSLS, K.TRNS, # 2
    K.TRNS, K.NO,   K.NO,   K.NO,   K.NO,   K.NO,   K.PEQL, K.KP_1, K.KP_2, K.KP_3, K.LPRN, K.RPRN, K.TRNS, # 3
    K.TRNS, K.TRNS, K.TRNS, K.LALT, K.SPC,  K.SPC,  K.KP_0, K.PDOT, K.TRNS, K.TRNS, K.TRNS, K.NO,   K.TRNS, # 4
  ],
  [ # 2 - Symbols
    # 1     2       3       4       5       6       7       8       9       10      11      12      13
    K.ESC,  K.F1,   K.F2,   K.F3,   K.F4,   K.F5,   K.F6,   K.F7,   K.F8,   K.F9,   K.F10,  K.F11,  K.F12,  # 1
    K.GRV,  K.N1,   K.N2,   K.N3,   K.N4,   K.N5,   K.N6,   K.N7,   K.N8,   K.N9,   K.N0,   K.MINS, K.EQL,  # 2
    K.TRNS, K.NO,   K.NO,   K.NO,   K.NO,   K.NO,   K.NO,   K.NO,   K.NO,   K.NO,   K.NO,   K.RSFT, K.TRNS, # 3
    K.TRNS, K.TRNS, K.NO,   K.TRNS, K.LCTL, K.LGUI, K.LALT, K.NO,   K.TRNS, K.TRNS, K.TRNS, K.TRNS, K.TRNS, # 4
  ],
  [ # 3 - Navigation
    # 1     2       3       4       5       6       7       8       9       10      11      12      13
    K.ESC,  RCON,   FCON,   DIST,   SRNK,   GROW,   K.NO,   K.PGUP, K.UP,   K.PGDN, K.NO,   RSEC,   FSEC,   # 1
    K.TRNS, RTAB,   FTAB,   FLOT,   ROTL,   ROTR,   K.HOME, K.LEFT, K.DOWN, K.RGHT, K.END,  K.NO,   GAPS,   # 2
    K.TRNS, WKSP1,  WKSP2,  WKSP3,  WKSP4,  WKSP5,  WKSP6,  WKSP7,  WKSP8,  WKSP9,  WKSP0,  K.NO,   K.PGUP, # 3
    K.TRNS, K.TRNS, K.TRNS, SFLK,   K.LCTL, K.LGUI, K.LALT, K.INS,  K.HOME, K.PGDN, K.END,  K.TRNS, K.TRNS, # 4
  ],
  [ # 4 - Media
    # 1     2       3       4       5       6       7       8       9       10      11      12      13
    K.ESC,  K.NO,   K.NO,   K.NO,   K.NO,   K.NO,   K.NO,   K.NO,   K.NO,   K.NO,   K.MPLY, K.MPRV, K.MNXT, # 1
    K.NO,   K.NO,   K.NO,   K.NO,   K.NO,   K.NO,   K.NO,   K.NO,   K.NO,   K.NO,   K.NO,   K.NO,   K.NO,   # 2
    K.TRNS, K.NO,   K.NO,   K.NO,   K.NO,   K.NO,   K.NO,   K.NO,   K.VOLD, K.VOLU, K.MUTE, MICM,   K.BRIU, # 3
    K.TRNS, K.TRNS, K.NO,   K.NO,   K.NO,   K.NO,   K.LSFT, K.TRNS, K.NO,   K.BRID, K.NO,   K.NO,   K.PSCR, # 4
  ],
  [ # 5 - PTT
    # 1     2       3       4       5       6       7       8       9       10      11      12      13
    K.NO,   K.NO,   K.NO,   K.NO,   K.NO,   K.NO,   K.NO,   K.NO,   K.NO,   K.NO,   K.NO,   K.NO,   K.NO,   # 1
    K.NO,   K.NO,   K.NO,   K.NO,   K.NO,   K.NO,   K.NO,   K.NO,   K.NO,   K.NO,   K.NO,   K.NO,   K.NO,   # 2
    K.NO,   K.NO,   K.NO,   K.NO,   K.NO,   K.NO,   K.NO,   K.NO,   K.NO,   K.NO,   K.NO,   K.NO,   K.NO,   # 3
    K.TRNS, K.TRNS, K.NO,   K.NO,   K.NO,   K.NO,   K.NO,   K.NO,   K.NO,   K.NO,   K.NO,   K.NO,   K.NO,   # 4
  ],
]

if __name__ == '__main__':
  for i in range(3):
    led.value = True
    time.sleep(0.1)
    led.value = False
    time.sleep(0.4)

  led.value = True
  time.sleep(0.5)
  led.value = False

  keyboard.go()
