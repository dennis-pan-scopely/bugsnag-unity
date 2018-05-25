using System;
using UnityEngine;

namespace Bugsnag.Unity
{
  public class Bugsnag : MonoBehaviour
  {
    /// <summary>
    /// Exposed in the Unity Editor to configure this behaviour
    /// </summary>
    public string BugsnagApiKey = "";

    /// <summary>
    /// Exposed in the Unity Editor to configure this behaviour
    /// </summary>
    public bool AutoNotify = true;

    public LogType NotifyLevel = LogType.Exception;

    public int MaximumBreadcrumbs = 25;

    public int UniqueLogsPerSecond = 5;

    /// <summary>
    /// Awake is called when the script instance is being loaded.
    /// We use this to pull the fields that have been set in the
    /// Unity editor and pass them to the Bugsnag client.
    /// </summary>
    void Awake()
    {
      Client.Instance.Configuration.ApiKey = BugsnagApiKey;
      Client.Instance.Configuration.AutoNotify = AutoNotify;
      Client.Instance.Configuration.UniqueLogsTimePeriod = TimeSpan.FromSeconds(UniqueLogsPerSecond);
      Client.Instance.Configuration.NotifyLevel = NotifyLevel;
      Client.Instance.Configuration.ReleaseStage = Debug.isDebugBuild ? "debug" : "production";
      Client.Instance.Configuration.MaximumBreadcrumbs = MaximumBreadcrumbs;
    }
  }


#if UNITY_EDITOR
  [UnityEditor.CustomEditor(typeof(Bugsnag))]
  [UnityEditor.CanEditMultipleObjects]
  public class BugsnagEditor : UnityEditor.Editor
  {
    UnityEditor.SerializedProperty apiKey;
    UnityEditor.SerializedProperty autoNotify;
    UnityEditor.SerializedProperty notifyLevel;
    UnityEditor.SerializedProperty maximumBreadcrumbs;
    UnityEditor.SerializedProperty uniqueLogsPerSecond;

    void OnEnable()
    {
      apiKey = serializedObject.FindProperty("BugsnagApiKey");
      autoNotify = serializedObject.FindProperty("AutoNotify");
      notifyLevel = serializedObject.FindProperty("NotifyLevel");
      maximumBreadcrumbs = serializedObject.FindProperty("MaximumBreadcrumbs");
      uniqueLogsPerSecond = serializedObject.FindProperty("UniqueLogsPerSecond");
    }

    public override void OnInspectorGUI()
    {
      serializedObject.Update();

      UnityEditor.EditorGUILayout.PropertyField(apiKey, new GUIContent("API Key"));
      UnityEditor.EditorGUILayout.PropertyField(autoNotify, new GUIContent("Auto Notify"));
      UnityEditor.EditorGUILayout.PropertyField(notifyLevel, new GUIContent("Notify Level"));
      UnityEditor.EditorGUILayout.PropertyField(maximumBreadcrumbs, new GUIContent("Maximum Breadcrumbs"));
      UnityEditor.EditorGUILayout.PropertyField(uniqueLogsPerSecond, new GUIContent("uniqueLogsPerSecond"));

      serializedObject.ApplyModifiedProperties();
    }
  }
#endif
}
