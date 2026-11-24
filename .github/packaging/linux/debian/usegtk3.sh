#!/bin/bash
#  Add a pre test to choose if we need to activate
# wx with same toolkit as python
WX=$(wx-config --query-toolkit)
PY=$(python3 -c "import wx; print(wx.version().split(' ')[1])")

if wx-config --toolkit=$PY &> /dev/null; then
    echo "\"--toolkit=$PY\""
else
    echo ""
fi
