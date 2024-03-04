#region usings
using System;
using System.ComponentModel.Composition;
using System.IO;

using VVVV.PluginInterfaces.V1;
using VVVV.PluginInterfaces.V2;
using VVVV.Utils.VColor;
using VVVV.Utils.VMath;

using VVVV.Core.Logging;
#endregion usings

namespace VVVV.Nodes
{
	#region PluginInfo
	[PluginInfo(Name = "WS2811", Category = "Color", Help = "Prepares the Raw Binary Stream necessary to feed the DMA pattern of a Teensy", Tags = "led, neopixel, stoffregen", Author="velcrome")]
	#endregion PluginInfo
	public class ColorOctifyNode : IPluginEvaluate, IPartImportsSatisfiedNotification
	{
		public enum ColorComponentOrder {
			RGB,
			GRB,
			RBG,
			BRG,
			GBR,
			BGR
		}
		
		protected byte[] Order = new byte[3] {1, 0, 2}; 
		
		#region fields & pins
		[Input("Input", DefaultColor = new double[] {
			0.1,
			0.2,
			0.3,
			1.0
		})]
		public ISpread<RGBAColor> FInput;

		[Input("Strip Length", DefaultValue = 128, IsSingle = true, MinValue = 1)]
		public ISpread<int> StripLength;

		[Input("Component Order", DefaultEnumEntry = "GRB", IsSingle = true)]
		public IDiffSpread<ColorComponentOrder> ComponentOrder;
		
		
		[Output("Output")]
		public ISpread<Stream> FOutput;

		[Import()]
		public ILogger FLogger;
		#endregion fields & pins

		public void OnImportsSatisfied()
		{
			ComponentOrder.Changed += ChangeOrder;
		}
		
		//called when data for any output pin is requested
		public void Evaluate(int SpreadMax)
		{
			SpreadMax = (int) Math.Ceiling(FInput.SliceCount / (StripLength[0]*8.0));
			FOutput.ResizeAndDispose(SpreadMax, () => new MemoryStream(GetLength()));
			
			for (int teensy = 0; teensy < SpreadMax; teensy++) {
				var output = FOutput[teensy] ?? new MemoryStream(GetLength());
				output.SetLength(GetLength());
				output.Seek(0, SeekOrigin.Begin);

				for (int x = 0; x < StripLength[0];x++) {
					for (byte color = 0; color < 3; color++) {
						
						byte mask = 0;
						byte[] components = new byte[8];

						for (int stripe = 0; stripe < 8; stripe++) {
							var led = FInput[teensy * 8 * StripLength[0] + x + stripe * StripLength[0]];
							components[stripe] = GetComponent(led, color);
						}

						
						byte[] pwm = new byte[8];

						for (int bit = 0; bit < 8; bit++) {
							mask = (byte)(1 << bit);
							pwm[7-bit] = 0;
						
							for (byte pin = 0;pin<8;pin++) {
								pwm[7-bit] += (byte)(((components[pin] & mask) >> bit) << pin); // each byte contains 8 bits across all 8 pins. this way octows2811 can modulate the pwms superfast
							}							
						}							
						
						output.Write(pwm, 0, 8);
						
					}
				}
				FOutput[teensy] = output;
			}
		}
		
		protected byte GetComponent(RGBAColor led, byte index) {
			byte result = 0;
			switch (Order[index]) {
				case 0: result = (byte)((led.R * 255)%256);
						break;
				case 1: result = (byte)((led.G * 255)%256);
						break;
				case 2: result = (byte)((led.B * 255)%256);
						break;
				}		
			return result;			
		}
		
		protected int GetLength() {
			return 3 * 8 * StripLength[0];
		}
		
		protected void ChangeOrder(IDiffSpread<ColorComponentOrder> spread) {
			for (int i=0;i<3;i++) {
				var color = ComponentOrder[0].ToString()[i];
				
				switch (color) {
					case 'R': Order[i] = 0;
					break;
					case 'G': Order[i] = 1;
					break;
					case 'B': Order[i] = 2;
					break;
				}
			}
		}		
	}
}
