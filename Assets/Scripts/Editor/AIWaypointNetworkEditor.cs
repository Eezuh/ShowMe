using UnityEditor;
using UnityEngine;
using UnityEngine.AI;

[CustomEditor(typeof(AIWaypointNetwork))]
public class AIWaypointNetworkEditor : Editor
{
    void OnSceneGUI()
    {
        AIWaypointNetwork network = (AIWaypointNetwork)target;

        for (int i = 0; i < network.Waypoints.Count; i++)
        {
            if (network.Waypoints[i] != null)
            {
                Handles.Label(network.Waypoints[i].position, "Waypoint " + i.ToString());
            }
        }

        if (network.displayMode == PathDisplayMode.Connections)
        {
            Vector3[] wayPointPositions = new Vector3[network.Waypoints.Count + 1];

            for (int i = 0; i <= network.Waypoints.Count; i++)
            {
                int index = i != network.Waypoints.Count ? i : 0;
                if (network.Waypoints[index] != null)
                {
                    wayPointPositions[i] = network.Waypoints[index].position;
                }
                else
                {
                    wayPointPositions[i] = new Vector3(Mathf.Infinity, Mathf.Infinity, Mathf.Infinity);
                }
            }

            Handles.color = Color.cyan;
            Handles.DrawPolyLine(wayPointPositions);
        }
        else if (network.displayMode == PathDisplayMode.Paths)
        {
            NavMeshPath path = new NavMeshPath();

            if (network.Waypoints[network.UIStart].position != null && network.Waypoints[network.UIEnd].position != null)
            {
                Vector3 startPoint = network.Waypoints[network.UIStart].position;
                Vector3 endPoint = network.Waypoints[network.UIEnd].position;

                NavMesh.CalculatePath(startPoint, endPoint, NavMesh.AllAreas, path);

                Handles.color = Color.green;
                Handles.DrawPolyLine(path.corners);
            }
        }
    }

    public override void OnInspectorGUI()
    {
        AIWaypointNetwork network = (AIWaypointNetwork)target;


        network.displayMode = (PathDisplayMode)EditorGUILayout.EnumPopup("Display Mode", network.displayMode);
        if (network.displayMode == PathDisplayMode.Paths)
        {
            string[] waypointNames = new string[network.Waypoints.Count];

            for (int i = 0; i < network.Waypoints.Count; i++)
            {
                if (network.Waypoints[i] != null)
                {
                    waypointNames[i] = network.Waypoints[i].name;
                }
            }

            network.UIStart = EditorGUILayout.Popup("Waypoint Start", network.UIStart, waypointNames);
            network.UIEnd = EditorGUILayout.Popup("Waypoint End", network.UIEnd, waypointNames);
        }
        
        DrawDefaultInspector();
        
    }
}
