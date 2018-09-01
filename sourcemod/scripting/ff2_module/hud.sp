Handle OnDisplayHud, OnDisplayHudPost;

// Native things

void HudInit()
{
    CreateNative("FF2HudDisplay.ShowSyncHudDisplayText", Native_FF2HudDisplay_ShowSyncHudDisplayText);
    CreateNative("FF2HudQueue.ShowSyncHudQueueText", Native_FF2HudQueue_ShowSyncHudQueueText);

    OnDisplayHud = CreateGlobalForward("FF2_OnDisplayHud", ET_Hook, Param_Cell, Param_String, Param_String);
    OnDisplayHudPost = CreateGlobalForward("FF2_OnDisplayHud_Post", ET_Hook, Param_Cell, Param_String, Param_String);
}

public int Native_FF2HudDisplay_ShowSyncHudDisplayText(Handle plugin, int numParams)
{
    FF2HudDisplay displayArray = GetNativeCell(1);
    int client = GetNativeCell(2);
    Handle sync = GetNativeCell(3);
    char info[64], display[64];

    displayArray.GetInfo(info, 64);
    displayArray.GetDisplay(display, 64);
    Action action = Forward_OnDisplayHud(client, info, display);
    if(action != Plugin_Handled && action != Plugin_Stop)
    {
        if(sync != null)
            FF2_ShowSyncHudText(client, sync, display);
        else
            FF2_ShowHudText(client, -1, display);
    }
}

public int Native_FF2HudQueue_ShowSyncHudQueueText(Handle plugin, int numParams)
{
    FF2HudQueue queue = GetNativeCell(1);
    Handle sync = GetNativeCell(2);
    FF2HudDisplay displayArray;

    char text[300], info[64], display[64];
    int displayCount = 0;
    Forward_OnCalledQueue(queue);

    for(int loop = 1; loop < queue.Length; loop++)
    {
        displayArray = queue.GetHud(loop);
        if(displayArray == null)
            continue;

        displayCount++;
        displayArray.GetInfo(info, 64);
        displayArray.GetDisplay(display, 64);
        Action action = Forward_OnDisplayHud(queue.ClientIndex, info, display);

        if(action != Plugin_Handled && action != Plugin_Stop)
        {
            if(displayCount > 1)
                Format(text, sizeof(text), "%s | ", text);
            Format(text, sizeof(text), "%s%s", text, display);
        }
    }

    if(sync != null)
        FF2_ShowSyncHudText(queue.ClientIndex, sync, text);
    else
        FF2_ShowHudText(queue.ClientIndex, -1, text);
}

public Action Forward_OnDisplayHud(int client, const char[] info, char[] display)
{
    Action action;
    char[] tempDisplay = new char[strlen(display)+1];
    Format(tempDisplay, strlen(tempDisplay)*2, "%s", display);

    Call_StartForward(OnDisplayHud);
    Call_PushCell(client);
    Call_PushString(info);
    Call_PushStringEx(tempDisplay, strlen(tempDisplay)*2, SM_PARAM_STRING_UTF8 | SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
    Call_Finish(action);

    if(action == Plugin_Changed)
    {
        strcopy(display, strlen(display)*2, tempDisplay);
    }

    Forward_OnDisplayHudPost(client, info, display);
    return Plugin_Continue;
}

public void Forward_OnDisplayHudPost(int client, const char[] info, const char[] display)
{
    Call_StartForward(OnDisplayHudPost);
    Call_PushCell(client);
    Call_PushString(info);
    Call_PushString(display);
    Call_Finish();
}
