import XMonad
import qualified XMonad.StackSet as W
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.SetWMName
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.WorkspaceCompare
import XMonad.Util.EZConfig(additionalKeysP)
import System.IO

main = do
    xmproc <- spawnPipe "xmobar"
    xmonad $ ewmh defaultConfig
        { borderWidth = 3
        , layoutHook  = myLayoutHook
        , logHook     = myLogHook xmproc >> setWMName "LG3D"
        , manageHook  = myManageHook <+> manageDocks
        , terminal    = "sakura -f Inconsolata,Medium\\ 15"
        , workspaces  = myWorkspaces
        } `additionalKeysP` myKeys

myLayoutHook = avoidStruts $ layouts
    where layouts = tiled ||| Mirror tiled ||| Full
          tiled   = Tall 1 (3/100) (1/2)

myLogHook xmproc = dynamicLogWithPP xmobarPP
    { ppOutput  = hPutStrLn xmproc
    , ppTitle   = xmobarColor "#00FF00" "" . shorten 80
    , ppCurrent = xmobarColor "#FFFF00" "#666666" . wrap "[" "]"
    , ppVisible = xmobarColor "#FFFFFF" "" . wrap "[" "]"
    , ppUrgent  = xmobarColor "#FF0000" "" . wrap "*" "*"
    , ppHidden  = xmobarColor "#BBBBBB" ""
    , ppLayout  = xmobarColor "#FFA500" "" . wrap "<" ">"
    , ppSort    = getSortByXineramaRule
    , ppSep     = "  "
    }

myManageHook = composeAll
    [ resource =? "stalonetray"        --> doIgnore
    , resource =? "qemu-system-x86_64" --> doFloat
    , resource =? "rdesktop"           --> doFloat
    , resource =? "vncviewer"          --> doFloat
    , isFullscreen                     --> doFullFloat
    ]

myWorkspaces = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]

myKeys =
    [ ("M-p"              , spawn "dmenu_run")
    , ("M-f"              , spawn "firefox")
    , ("M-g"              , spawn "gvim")
    , ("<XF86AudioLowerVolume>"      , spawn "amixer -q set Master 2dB-")
    , ("<XF86AudioRaiseVolume>"      , spawn "amixer -q set Master 2dB+")
    , ("<XF86AudioMute>"             , spawn "amixer -q set Master toggle")
    , ("M-S-z", spawn "xscreensaver-command -lock")
    ]
