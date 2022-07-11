/*
  VIRUS LQP-79: http://www.team-arg.org/zmbt-manual.html

  Arduboy version 1.6.0:  http://www.team-arg.org/zmbt-downloads.html

  MADE by TEAM a.r.g. : http://www.team-arg.org/more-about.html

  2016 - FUOPY - JO3RI - STG - CASTPIXEL - JUSTIN CYR

  Game License: MIT : https://opensource.org/licenses/MIT

  Shader version 0.1.0:  https://github.com/fuopy/viruslqp79-shader

  PORTED by FUOPY : https://github.com/fuopy

  2021 - FUOPY

*/

using UdonSharp;
using UnityEngine;
using VRC.SDKBase;
using VRC.Udon;

[UdonBehaviourSyncMode(BehaviourSyncMode.Manual)]
public class s_logic_viruslqp : UdonSharpBehaviour
{
    public Material gameLogicMaterial;
    private float isLocalPlayerOwner = 0.0f;
    public CustomRenderTexture tex2;
    public Texture2D tex;
    private Camera cam;

    [UdonSynced] public float[] Net_FrameHistory;
    [UdonSynced] public float[] Net_InputHistory;
    [UdonSynced] public int Net_HistoryLength;

    void Start()
    {
        Debug.Log("[Fuopy][Start] Enter");
        Net_FrameHistory = new float[64];
        Net_InputHistory = new float[64];
        Debug.Log("[Fuopy][Start] 2");

        if (Networking.LocalPlayer.IsOwner(gameObject))
        {
            cam = gameObject.GetComponent<Camera>();
            isLocalPlayerOwner = 1.0f;
            SendCustomEventDelayedSeconds("_cameraToggle", 1.0f);
        }
        Debug.Log("[Fuopy][Start] Exit");
    }

    public void _cameraToggle()
    {
        // Debug.Log("[Fuopy][_cameraToggle] Enter");
        cam.enabled = true;
        // Debug.Log("[Fuopy][_cameraToggle] Exit");
    }

    // Called when the camera is enabled. Camera will be enabled once per second.
    void OnPostRender()
    {
        // Debug.Log("[Fuopy][OnPostRender] Enter");
        Communication_ScanInputBuffer();
        
        cam.enabled = false;
        SendCustomEventDelayedSeconds("_cameraToggle", 1.0f);
        // Debug.Log("[Fuopy][OnPostRender] Exit");
    }

    public override void Interact()
    {
        Debug.Log("[Fuopy][Interact] Enter");
        isLocalPlayerOwner = 1.0f;
        Debug.Log("[Fuopy][Interact] Exit");
    }

    private float _ColorToFloat(Color c)
    {
        //Debug.Log("[Fuopy][_ColorToFloat] Enter");
        return c.r * 255f + ((c.g * 255f) * 256 ) + ((c.b * 255f) * 256 * 256) + ((c.a * 255f) * 256 * 256 * 256);
    }

    public override void OnDeserialization()
    {
        Debug.Log("[Fuopy][OnDeserialization] Enter");
        Debug.Log($"[Fuopy][OnDeserialization] We got data of length: {Net_HistoryLength}");

        for (int i = 0; i < Net_HistoryLength; ++i)
        {
            Debug.Log($"[Fuopy][OnDeserialization] Data: ({i}, {Net_FrameHistory[i]}, {Net_InputHistory[i]})");
        }
        
        Debug.Log("[Fuopy][OnDeserialization] Setting MaterialPropertyBlock");
        gameLogicMaterial.SetFloatArray("_Recv_FrameHistory", Net_FrameHistory);
        gameLogicMaterial.SetFloatArray("_Recv_InputHistory", Net_InputHistory);

        Debug.Log("[Fuopy][OnDeserialization] Exit");
    }

    private void Communication_ScanInputBuffer()
    {
        //Debug.Log("[Fuopy][Communication_ScanInputBuffer] Enter");

        // Read the pixels.
        tex.ReadPixels(new Rect(0, 0, 128, 128), 0, 0, false);
        tex.Apply();

        // Get the pixels into UDON.
        Color[] inputHistoryBuffer = tex.GetPixels(0, 29, 64, 1);
        Color[] frameHistoryBuffer = tex.GetPixels(0, 30, 64, 1);

        float firstFrame = _ColorToFloat(frameHistoryBuffer[0]);
        float firstInput = _ColorToFloat(inputHistoryBuffer[0]);

        //Debug.Log($"[Fuopy][Communication_ScanInputBuffer] First Frame: {firstFrame}, First Input: {firstInput}");

        // Clear our list of inputs.
        Net_HistoryLength = 0;

        // Loop through all the stuff in the history and attach the frames.
        // Remove duplicate input states. Then serialize what is left over.
        float previousFrame = 0;
        float previousInput = 0;

        //Debug.Log("[Fuopy][Communication_ScanInputBuffer] 2");

        for (int i = 0; i < Net_InputHistory.Length; ++i)
        {
            //Debug.Log("[Fuopy][Communication_ScanInputBuffer] 3");

            float frame = _ColorToFloat(frameHistoryBuffer[i]);
            float input = _ColorToFloat(inputHistoryBuffer[i]);

            if (input == previousInput) continue;

            // Add this new pair to our serialization.
            Net_FrameHistory[Net_HistoryLength] = frame;
            Net_InputHistory[Net_HistoryLength] = input;
            ++Net_HistoryLength;

            previousFrame = frame;
            previousInput = input;
        }

        // Clear out the remaining history buffer.
        for (int i = Net_HistoryLength; i < Net_InputHistory.Length; ++i)
        {
            //Debug.Log($"[Fuopy][Communication_ScanInputBuffer] 4, i={i}");
            Net_FrameHistory[i] = 0;
            Net_InputHistory[i] = 0;
        }
        //Debug.Log("[Fuopy][Communication_ScanInputBuffer] 5");

        // Request Serialization.
        RequestSerialization();
        
        //Debug.Log("[Fuopy][Communication_ScanInputBuffer] 5=6");
        //Debug.Log("[Fuopy][Communication_ScanInputBuffer] Exit");
    }

    private int Communication_PackInputState(float vx, float vy, bool b, bool a, bool power)
    {
        //Debug.Log("[Fuopy][Communication_PackInputState] Enter");
        int state = 0;

        if (a) state |= 1;
        if (b) state |= 2;
        if (vx < 0) state |= 4;
        if (vx > 0) state |= 8;
        if (vy < 0) state |= 16;
        if (vy > 0) state |= 32;
        if (power) state |= 64;

        return state;
    }

    private int Communication_GetInputState()
    {
        //Debug.Log("[Fuopy][Communication_GetInputState] Enter");
        var triggerDeadzone = .3;
        var stickDeadzone = .3;

        var b_button = Input.GetAxis("Oculus_CrossPlatform_SecondaryIndexTrigger") > triggerDeadzone;
        var a_button = Input.GetButton("Fire2") || Input.GetButton("Cancel");
        var power_button = Input.GetKey("p");

        b_button |= Input.GetKey("x") || Input.GetKey("j");
        a_button |= Input.GetKey("v") || Input.GetKey("k");

        float vx = Input.GetAxis("Oculus_CrossPlatform_PrimaryThumbstickHorizontal");
        float vy = -Input.GetAxis("Oculus_CrossPlatform_PrimaryThumbstickVertical");

        if (Mathf.Abs(vx) < stickDeadzone)
        {
            vx = 0;
        }
        if (Mathf.Abs(vy) < stickDeadzone)
        {
            vy = 0;
        }
        if (Input.GetKey("up") || Input.GetKey("w") || Input.GetKey("z"))
        {
            vy = -1;
        }
        else if (Input.GetKey("down") || Input.GetKey("s"))
        {
            vy = 1;
        }

        if (Input.GetKey("left") || Input.GetKey("a") || Input.GetKey("q"))
        {
            vx = -1;
        }
        else if (Input.GetKey("right") || Input.GetKey("d"))
        {
            vx = 1;
        }

        return Communication_PackInputState(vx, vy, b_button, a_button, power_button);
    }

    private void Update()
    {
        if (isLocalPlayerOwner < 1.0f) return;
        //Debug.Log("[Fuopy][Update] Enter");
        var inputState = Communication_GetInputState();
        gameLogicMaterial.SetFloat("_PlayerOneJoystick", inputState);
        gameLogicMaterial.SetFloat("_IsLocalPlayerOwner", isLocalPlayerOwner);
    }
}
